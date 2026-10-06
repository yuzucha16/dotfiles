#!/usr/bin/env bash
# Tests for scripts/linux (WSL and native Linux). Run: bash tests/linux/test_scripts.sh
#
# - Uses only a temp dir and a fake HOME; the real ~ is never changed.
# - WSL / native branches are forced with PROC_VERSION_FILE (a stand-in for /proc/version),
#   so both branches run on either kind of machine. A few checks look at the real environment.
# - External commands are faked: ghq by a stub on PATH, the clone source by a local bare repo (no network).
# - Exit code = number of failures.
set -u

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
T="$(mktemp -d)"
fail=0
total=0
ok() { total=$((total + 1)); echo "  PASS: $1"; }
ng() { total=$((total + 1)); fail=$((fail + 1)); echo "  FAIL: $1"; }
check() { if eval "$2"; then ok "$1"; else ng "$1"; fi; }
skip() { echo "  SKIP: $1"; }
. "$DOTS/scripts/linux/lib.sh"

echo "linux" > "$T/ver_native"
echo "Linux version 6.1 microsoft-standard-WSL2" > "$T/ver_wsl"
LINK="$DOTS/scripts/linux/30_link.sh"
REPOS="$DOTS/scripts/linux/50_repos.sh"

echo "== syntax / line endings"
for f in lib.sh 30_link.sh 50_repos.sh; do
  check "bash -n $f" 'bash -n "$DOTS/scripts/linux/$f"'
done
check "sh -n .profile (POSIX sh: $(readlink -f /bin/sh))" '/bin/sh -n "$DOTS/home/.profile"'
cr=$(cat "$DOTS/scripts/linux/lib.sh" "$LINK" "$REPOS" "$DOTS/home/.profile" | tr -cd '\r' | wc -c)
check "no CR in the edited files" '[[ "$cr" == 0 ]]'

echo "== .profile: WORKS_DIR"
r=$(env -i HOME=/home/u PATH="$PATH" PROC_VERSION_FILE="$T/ver_wsl" /bin/sh -c ". $DOTS/home/.profile; echo \$WORKS_DIR")
check "WSL -> /mnt/c/vault/works" '[[ "$r" == /mnt/c/vault/works ]]'
r=$(env -i HOME=/home/u PATH="$PATH" PROC_VERSION_FILE="$T/ver_native" /bin/sh -c ". $DOTS/home/.profile; echo \$WORKS_DIR")
check "native -> \$HOME/vault/works" '[[ "$r" == /home/u/vault/works ]]'
r=$(env -i HOME=/home/u PATH="$PATH" WORKS_DIR=/x/y PROC_VERSION_FILE="$T/ver_native" /bin/sh -c ". $DOTS/home/.profile; echo \$WORKS_DIR")
check "explicit WORKS_DIR wins" '[[ "$r" == /x/y ]]'
r=$(env -i HOME=/home/u PATH="$PATH" PROC_VERSION_FILE="$T/ver_wsl" /bin/sh -c ". $DOTS/home/.profile; env | grep -c '^WORKS_DIR='")
check "WORKS_DIR is exported" '[[ "$r" == 1 ]]'

echo "== lib.sh: works_dir"
r=$(WORKS_DIR=/a/b works_dir); check "explicit wins" '[[ "$r" == /a/b ]]'
r=$(unset WORKS_DIR; PROC_VERSION_FILE="$T/ver_wsl" works_dir); check "WSL" '[[ "$r" == /mnt/c/vault/works ]]'
r=$(unset WORKS_DIR; HOME=/home/u PROC_VERSION_FILE="$T/ver_native" works_dir); check "native" '[[ "$r" == /home/u/vault/works ]]'
r=$(unset WORKS_DIR; works_dir)
if is_wsl; then check "real environment (WSL) -> /mnt/c/vault/works" '[[ "$r" == /mnt/c/vault/works ]]'
else check "real environment (native) -> \$HOME/vault/works" '[[ "$r" == "$HOME/vault/works" ]]'; fi

echo "== lib.sh: clone_workbase (a local bare repo is the remote)"
git init -q "$T/src"
echo x > "$T/src/AGENTS.md"
git -C "$T/src" add AGENTS.md
git -C "$T/src" -c user.name=t -c user.email=t@example.invalid commit -q -m init
git clone -q --bare "$T/src" "$T/workbase.git"
N="$T/n1"
clone_workbase "$N" "$T/workbase.git" >/dev/null 2>&1
check "fresh clone (parent created)" '[[ -d "$N/resources/.git" && -f "$N/resources/AGENTS.md" ]]'
out=$(clone_workbase "$N" "$T/workbase.git" 2>&1)
check "skip when already cloned" '[[ "$out" == *"[SKIP]"* ]]'
N2="$T/n2"; mkdir -p "$N2/resources"; echo x > "$N2/resources/f"
clone_workbase "$N2" "$T/workbase.git" >/dev/null 2>&1; rc=$?
check "non-empty non-git dir -> ERR (rc=1), untouched" '[[ $rc -eq 1 && -f "$N2/resources/f" ]]'
N3="$T/n3"; mkdir -p "$N3/resources"
clone_workbase "$N3" "$T/workbase.git" >/dev/null 2>&1
check "empty existing dir -> clone ok" '[[ -d "$N3/resources/.git" ]]'

echo "== lib.sh: link_obsidian"
S="$T/src2/.obsidian"; mkdir -p "$S"; echo '{}' > "$S/app.json"
D="$T/nn/.obsidian"
link_obsidian link "$S" "$D" 1 >/dev/null
check "dry-run creates nothing" '[[ ! -e "$T/nn" ]]'
link_obsidian link "$S" "$D" 0 >/dev/null
check "link: symlink + parent created" '[[ -L "$D" && -f "$D/app.json" ]]'
link_obsidian link "$S" "$D" 0 >/dev/null
check "re-link ok" '[[ -L "$D" ]]'
link_obsidian unlink "$S" "$D" 1 >/dev/null
check "unlink dry-run keeps the link" '[[ -L "$D" ]]'
link_obsidian unlink "$S" "$D" 0 >/dev/null
check "unlink removes the symlink only" '[[ ! -L "$D" && -d "$S" ]]'
mkdir -p "$D"; echo keep > "$D/f"
link_obsidian link "$S" "$D" 0 >/dev/null 2>&1; rc=$?
check "real dir -> ERR (rc=1), untouched" '[[ $rc -eq 1 && -f "$D/f" && ! -L "$D" ]]'
link_obsidian unlink "$S" "$D" 0 >/dev/null
check "unlink leaves a real dir" '[[ -f "$D/f" ]]'
D2="$T/nn2/.obsidian"; mkdir -p "$T/nn2"; ln -s "$T/gone" "$D2"
link_obsidian link "$S" "$D2" 0 >/dev/null
check "dangling symlink is replaced" '[[ -f "$D2/app.json" ]]'
link_obsidian link "$T/nosrc" "$T/nn3/.obsidian" 0 >/dev/null
check "missing source -> skip, nothing created" '[[ ! -e "$T/nn3" ]]'

echo "== 30_link.sh end to end (fake HOME; needs stow)"
if command -v stow >/dev/null 2>&1; then
  FH="$T/fh"; mkdir -p "$FH"
  out=$(PROC_VERSION_FILE="$T/ver_wsl" WORKS_DIR="$T/wworks" bash "$LINK" link -n --dst "$FH" 2>&1); rc=$?
  check "WSL dry-run: rc=0, no .obsidian handling" '[[ $rc -eq 0 && "$out" != *obsidian* ]]'
  out=$(PROC_VERSION_FILE="$T/ver_native" WORKS_DIR="$T/nworks" bash "$LINK" link -n --dst "$FH" 2>&1); rc=$?
  check "native dry-run: rc=0 + [DRY] .obsidian, nothing created" '[[ $rc -eq 0 && "$out" == *"[DRY] link $T/nworks/.obsidian"* && ! -e "$T/nworks" ]]'
  out=$(PROC_VERSION_FILE="$T/ver_native" WORKS_DIR="$T/nworks" bash "$LINK" link --dst "$FH" 2>&1); rc=$?
  check "native link: rc=0, .obsidian -> dotfiles, home files stowed" '[[ $rc -eq 0 && "$(readlink "$T/nworks/.obsidian")" == "$DOTS/windows/obsidian/.obsidian" && -L "$FH/.profile" ]]'
  out=$(PROC_VERSION_FILE="$T/ver_native" WORKS_DIR="$T/nworks" bash "$LINK" unlink --dst "$FH" 2>&1); rc=$?
  check "native unlink: .obsidian link removed, home files unstowed" '[[ $rc -eq 0 && ! -e "$T/nworks/.obsidian" && ! -L "$FH/.profile" ]]'
  mkdir -p "$T/nworks/.obsidian"; echo keep > "$T/nworks/.obsidian/x"
  out=$(PROC_VERSION_FILE="$T/ver_native" WORKS_DIR="$T/nworks" bash "$LINK" link --dst "$FH" 2>&1); rc=$?
  check "native link with a real .obsidian: rc=1 + [ERR], untouched" '[[ $rc -eq 1 && "$out" == *"[ERR] real file/dir exists"* && -f "$T/nworks/.obsidian/x" ]]'
else
  skip "stow is not installed"
fi

echo "== 50_repos.sh (stub ghq, fake HOME)"
FH2="$T/fh2"; mkdir -p "$FH2" "$T/bin"; : > "$FH2/.profile"
printf '#!/bin/sh\necho "ghq-stub $*"\n' > "$T/bin/ghq"; chmod +x "$T/bin/ghq"
out=$(HOME="$FH2" PATH="$T/bin:$PATH" PROC_VERSION_FILE="$T/ver_native" WORKS_DIR="$T/n50" WORKBASE_URL="$T/workbase.git" bash "$REPOS" 2>&1); rc=$?
check "native: cloned, then ghq stub called" '[[ $rc -eq 0 && -d "$T/n50/resources/.git" && "$out" == *ghq-stub* ]]'
out=$(HOME="$FH2" PATH="$T/bin:$PATH" PROC_VERSION_FILE="$T/ver_native" WORKS_DIR="$T/n50" WORKBASE_URL="$T/workbase.git" bash "$REPOS" 2>&1); rc=$?
check "native re-run: skip" '[[ $rc -eq 0 && "$out" == *"[SKIP] already cloned"* ]]'
out=$(HOME="$FH2" PATH="$T/bin:$PATH" PROC_VERSION_FILE="$T/ver_wsl" WORKS_DIR="$T/n51" bash "$REPOS" 2>&1); rc=$?
check "WSL: WARN when not cloned, no clone, ghq still runs" '[[ $rc -eq 0 && "$out" == *"[WARN] WSL"* && ! -e "$T/n51" && "$out" == *ghq-stub* ]]'
out=$(HOME="$FH2" PATH="$T/bin:$PATH" PROC_VERSION_FILE="$T/ver_wsl" WORKS_DIR="$T/n50" bash "$REPOS" 2>&1); rc=$?
check "WSL: SKIP when already cloned" '[[ $rc -eq 0 && "$out" == *"[SKIP] workbase already cloned (Windows side)"* ]]'
if is_wsl && [[ -d /mnt/c/vault/works/resources/.git ]]; then
  out=$(unset WORKS_DIR; HOME="$FH2" PATH="$T/bin:$PATH" bash "$REPOS" 2>&1); rc=$?
  check "real WSL: default WORKS_DIR sees the Windows-side clone" '[[ $rc -eq 0 && "$out" == *"[SKIP] workbase already cloned (Windows side): /mnt/c/vault/works/resources"* ]]'
else
  skip "real WSL check (needs WSL with /mnt/c/vault/works/resources)"
fi

echo
cd / || exit 1
rm -rf "$T"
echo "RESULT: $((total - fail))/$total passed, failures=$fail"
exit $fail
