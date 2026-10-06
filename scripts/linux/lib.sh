#!/usr/bin/env bash
# Shared helpers for scripts/linux (WSL and native Linux). Source it; do not run it.
#   . "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# dotfiles repo root (two levels above scripts/linux)
dots_dir() {
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
}

# true when running inside WSL (PROC_VERSION_FILE is only for tests)
is_wsl() {
  grep -qi microsoft "${PROC_VERSION_FILE:-/proc/version}" 2>/dev/null
}

# Vault top (WORKS_DIR): an existing WORKS_DIR wins.
# WSL shares C:\vault\works through /mnt/c; native Linux uses ~/vault/works
works_dir() {
  if [[ -n "${WORKS_DIR:-}" ]]; then
    echo "$WORKS_DIR"
  elif is_wsl; then
    echo "/mnt/c/vault/works"
  else
    echo "$HOME/vault/works"
  fi
}

# clone the shared repo (workbase) straight into <works_dir>/resources.
# Outside ghq on purpose: a link to a ghq path is not followed by Grep/Glob/rg. Skips when already cloned.
# usage: clone_workbase <works_dir> <url>
clone_workbase() {
  local works="$1" url="$2" dest="$1/resources"
  if [[ -d "$dest/.git" ]]; then
    echo "[SKIP] already cloned: $dest"
    return 0
  fi
  if [[ -e "$dest" && -n "$(ls -A "$dest" 2>/dev/null)" ]]; then
    echo "[ERR] $dest exists and is not empty (and is not a git repo). Move it by hand." >&2
    return 1
  fi
  mkdir -p "$works"
  git clone "$url" "$dest"
}

# link the Obsidian config (dotfiles windows/obsidian/.obsidian) to <works_dir>/.obsidian (native Linux only)
# usage: link_obsidian <link|unlink> <src> <dst> <dry 0|1>   (returns 1 on [ERR])
link_obsidian() {
  local mode="$1" src="$2" dst="$3" dry="$4"
  case "$mode" in
    link)
      if [[ ! -d "$src" ]]; then
        echo "[SKIP] no source: $src"
        return 0
      fi
      if [[ -e "$dst" && ! -L "$dst" ]]; then
        echo "[ERR] real file/dir exists, move it by hand: $dst" >&2
        return 1
      fi
      if (( dry == 1 )); then
        echo "[DRY] link $dst -> $src"
        return 0
      fi
      mkdir -p "$(dirname "$dst")"
      ln -sfn "$src" "$dst"
      echo "[OK] $dst -> $src"
      ;;
    unlink)
      if [[ -L "$dst" ]]; then
        if (( dry == 1 )); then
          echo "[DRY] unlink $dst"
        else
          unlink "$dst"
          echo "[OK] unlinked $dst"
        fi
      elif [[ -e "$dst" ]]; then
        echo "[SKIP] not a link, left alone: $dst"
      fi
      ;;
  esac
}

# distro IDs from /etc/os-release: "ubuntu debian" (ID, then ID_LIKE)
distro_ids() {
  ( . /etc/os-release && echo "${ID:-} ${ID_LIKE:-}" )
}

# true when the distro is (or derives from) the given ID, e.g. distro_is ubuntu
distro_is() {
  local id
  for id in $(distro_ids); do
    [[ "$id" == "$1" ]] && return 0
  done
  return 1
}

# print package names from a manifest (skip blank lines and # comments)
read_list() {
  local file="$1" line
  [[ -f "$file" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    line="${line%%#*}"
    line="${line//[[:space:]]/}"
    [[ -n "$line" ]] && echo "$line"
  done < "$file"
}
