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
for f in lib.sh 11_git_identity.sh 24_fonts.sh 30_link.sh 50_repos.sh; do
  check "bash -n $f" 'bash -n "$DOTS/scripts/linux/$f"'
done
check "sh -n .profile (POSIX sh: $(readlink -f /bin/sh))" '/bin/sh -n "$DOTS/home/.profile"'
cr=$(cat "$DOTS/scripts/linux/lib.sh" "$DOTS/scripts/linux/11_git_identity.sh" "$DOTS/scripts/linux/24_fonts.sh" "$LINK" "$REPOS" "$DOTS/home/.profile" | tr -cd '\r' | wc -c)
check "no CR in the edited files" '[[ "$cr" == 0 ]]'

echo "== .profile: WORKS_DIR"
r=$(env -i HOME=/home/u USER=u PATH="$PATH" PROC_VERSION_FILE="$T/ver_wsl" /bin/sh -c ". $DOTS/home/.profile; echo \$WORKS_DIR")
check "WSL -> /mnt/c/Users/\$USER/works (fallback)" '[[ "$r" == /mnt/c/Users/u/works ]]'
r=$(env -i HOME=/home/u USER=u PATH="$PATH" PROC_VERSION_FILE="$T/ver_native" /bin/sh -c ". $DOTS/home/.profile; echo \$WORKS_DIR")
check "native -> \$HOME/works" '[[ "$r" == /home/u/works ]]'
r=$(env -i HOME=/home/u USER=u PATH="$PATH" PROC_VERSION_FILE="$T/ver_native" /bin/sh -c ". $DOTS/home/.profile; echo \$GHQ_ROOT")
check "native GHQ_ROOT -> \$WORKS_DIR/repos" '[[ "$r" == /home/u/works/repos ]]'
r=$(env -i HOME=/home/u USER=u PATH="$PATH" PROC_VERSION_FILE="$T/ver_wsl" /bin/sh -c ". $DOTS/home/.profile; echo \$GHQ_ROOT")
check "WSL GHQ_ROOT -> \$HOME/vault/repos (Linux filesystem)" '[[ "$r" == /home/u/vault/repos ]]'
r=$(env -i HOME=/home/u PATH="$PATH" WORKS_DIR=/x/y PROC_VERSION_FILE="$T/ver_native" /bin/sh -c ". $DOTS/home/.profile; echo \$WORKS_DIR")
check "explicit WORKS_DIR wins" '[[ "$r" == /x/y ]]'
r=$(env -i HOME=/home/u PATH="$PATH" PROC_VERSION_FILE="$T/ver_wsl" /bin/sh -c ". $DOTS/home/.profile; env | grep -c '^WORKS_DIR='")
check "WORKS_DIR is exported" '[[ "$r" == 1 ]]'

echo "== lib.sh: works_dir"
r=$(WORKS_DIR=/a/b works_dir); check "explicit wins" '[[ "$r" == /a/b ]]'
r=$(unset WORKS_DIR; USER=u PROC_VERSION_FILE="$T/ver_wsl" works_dir); check "WSL" '[[ "$r" == /mnt/c/Users/u/works ]]'
r=$(unset WORKS_DIR; HOME=/home/u PROC_VERSION_FILE="$T/ver_native" works_dir); check "native" '[[ "$r" == /home/u/works ]]'
r=$(unset WORKS_DIR; works_dir)
if is_wsl; then check "real environment (WSL) -> /mnt/c/Users/\$USER/works (fallback)" '[[ "$r" == "/mnt/c/Users/$USER/works" ]]'
else check "real environment (native) -> \$HOME/works" '[[ "$r" == "$HOME/works" ]]'; fi

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
# WORKS_DIR is passed from Windows via WSLENV (WORKS_DIR/p); without it, this check is skipped (the WSL user name can differ)
if is_wsl && [[ -n "${WORKS_DIR:-}" && -d "$WORKS_DIR/resources/.git" ]]; then
  out=$(HOME="$FH2" PATH="$T/bin:$PATH" bash "$REPOS" 2>&1); rc=$?
  check "real WSL: WORKS_DIR from WSLENV sees the Windows-side clone" '[[ $rc -eq 0 && "$out" == *"[SKIP] workbase already cloned (Windows side): $WORKS_DIR/resources"* ]]'
else
  skip "real WSL check (needs WSL with WORKS_DIR passed via WSLENV and a clone at \$WORKS_DIR/resources)"
fi

echo "== 11_git_identity.sh (fake HOME; input from stdin)"
GI="$DOTS/scripts/linux/11_git_identity.sh"
gi() { # usage: gi <home> <stdin-text>; prints output, returns the script's rc
  printf '%b' "$2" | HOME="$1" bash "$GI" 2>&1
}
H1="$T/gi1"; mkdir -p "$H1"
out=$(gi "$H1" 'Taro Yamada\ntaro@example.com\n'); rc=$?
check "create: rc=0, [DONE]" '[[ $rc -eq 0 && "$out" == *"[DONE] created"* ]]'
check "create: user.name / user.email written" '[[ "$(git config --file "$H1/.gitconfig_local" user.name)" == "Taro Yamada" && "$(git config --file "$H1/.gitconfig_local" user.email)" == taro@example.com ]]'
check "create: no credential.helperselector (Windows-only setting)" '! grep -q helperselector "$H1/.gitconfig_local"'
H2="$T/gi2"; mkdir -p "$H2"; printf '[user]\n\tname = keep\n' > "$H2/.gitconfig_local"
out=$(gi "$H2" 'x\nx@y.z\n'); rc=$?
check "exists: [SKIP], rc=0, file unchanged" '[[ $rc -eq 0 && "$out" == *"[SKIP] already exists"* && "$(git config --file "$H2/.gitconfig_local" user.name)" == keep ]]'
H3="$T/gi3"; mkdir -p "$H3"
out=$(gi "$H3" '\nHanako\n\nhanako@example.com\n'); rc=$?
check "empty name / email -> warns and asks again" '[[ $rc -eq 0 && "$out" == *"user.name must not be empty"* && "$out" == *"user.email must not be empty"* && "$(git config --file "$H3/.gitconfig_local" user.name)" == Hanako ]]'
H4="$T/gi4"; mkdir -p "$H4"
out=$(gi "$H4" 'Jiro\nnot-an-email\njiro@example.com\n'); rc=$?
check "email without @ -> warns and asks again" '[[ $rc -eq 0 && "$out" == *"should contain"* && "$(git config --file "$H4/.gitconfig_local" user.email)" == jiro@example.com ]]'
H5="$T/gi5"; mkdir -p "$H5"
out=$(gi "$H5" 'A & B 100% $HOME\nab@example.com\n'); rc=$?
check "special characters in the name are kept literally" '[[ "$(git config --file "$H5/.gitconfig_local" user.name)" == "A & B 100% \$HOME" ]]'
H6="$T/gi6"; mkdir -p "$H6"
out=$(HOME="$H6" bash "$GI" 2>&1 </dev/null); rc=$?
check "closed stdin: gives up with [ERR] after 5 tries (rc=1), no file" '[[ $rc -eq 1 && "$out" == *"no valid input after 5 tries"* && ! -e "$H6/.gitconfig_local" ]]'
H7="$T/gi7"; mkdir -p "$H7"
out=$(printf 'x\nx@y.z\n' | HOME="$H7" PATH=/nonexistent /bin/bash "$GI" 2>&1); rc=$?
check "no git: [ERR] (rc=1), no file" '[[ $rc -eq 1 && "$out" == *"git not found"* && ! -e "$H7/.gitconfig_local" ]]'

echo "== 24_fonts.sh (fake gh, fake tree with a 2-font list, fake HOME)"
FT="$T/ft"; mkdir -p "$FT/scripts/linux" "$FT/manifests" "$T/hf" "$T/bin2"
cp "$DOTS/scripts/linux/24_fonts.sh" "$DOTS/scripts/linux/lib.sh" "$FT/scripts/linux/"
printf 'a/one:one_v*.zip\nb/two:two_v*.zip\n' > "$FT/manifests/fonts.txt"
# fake gh: records the call; fails when the repo is in $GH_FAIL
printf '#!/bin/sh\necho "gh-stub $*" >> "$GH_LOG"\ncase " $* " in *" $GH_FAIL "*) exit 1;; esac\nexit 0\n' > "$T/bin2/gh"; chmod +x "$T/bin2/gh"
GHL="$T/gh.log"; : > "$GHL"
out=$(HOME="$T/hf" PATH="$T/bin2:$PATH" GH_LOG="$GHL" GH_FAIL="none/none" bash "$FT/scripts/linux/24_fonts.sh" 2>&1); rc=$?
check "all ok: rc=0, both fonts requested, destination created" '[[ $rc -eq 0 && "$(grep -c gh-stub "$GHL")" == 2 && -d "$T/hf/download" && "$out" == *"Downloaded to"* ]]'
: > "$GHL"
out=$(HOME="$T/hf" PATH="$T/bin2:$PATH" GH_LOG="$GHL" GH_FAIL="a/one" bash "$FT/scripts/linux/24_fonts.sh" 2>&1); rc=$?
check "first fails: continues with the second, [ERROR], rc=1, no 'Downloaded to'" '[[ $rc -eq 1 && "$(grep -c gh-stub "$GHL")" == 2 && "$out" == *"[ERROR] download failed: a/one"* && "$out" != *"Downloaded to"* ]]'
mkdir -p "$T/bin3"; ln -sf "$(command -v dirname)" "$T/bin3/dirname"   # the script needs dirname (lib.sh), but not gh
out=$(HOME="$T/hf" PATH="$T/bin3" GH_LOG="$GHL" /bin/bash "$FT/scripts/linux/24_fonts.sh" 2>&1); rc=$?
check "no gh: [ERR] (rc=1)" '[[ $rc -eq 1 && "$out" == *"gh not found"* ]]'

echo
cd / || exit 1
rm -rf "$T"
echo "RESULT: $((total - fail))/$total passed, failures=$fail"
exit $fail
