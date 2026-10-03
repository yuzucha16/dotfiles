#!/usr/bin/env bash
# Shared helpers for scripts/linux (WSL and native Linux). Source it; do not run it.
#   . "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# dotfiles repo root (two levels above scripts/linux)
dots_dir() {
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
}

# true when running inside WSL
is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
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
