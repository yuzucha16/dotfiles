#!/usr/bin/env bash
set -eu

# set current setting
source ~/.profile
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# workbase (shared knowledge repo): clone straight into the vault top, outside ghq
# (a link to a ghq path is not followed by Grep/Glob/rg).
# WSL: the Windows side (scripts\windows\50_repos.bat) clones it into C:\vault\works\resources, shared via /mnt/c.
: "${WORKBASE_URL:=https://github.com/yuzucha16/workbase}"
WORKS="$(works_dir)"
if is_wsl; then
  if [[ -d "$WORKS/resources/.git" ]]; then
    echo "[SKIP] workbase already cloned (Windows side): $WORKS/resources"
  else
    echo "[WARN] WSL: run scripts\\windows\\50_repos.bat on Windows to clone workbase into $WORKS/resources"
  fi
else
  clone_workbase "$WORKS" "$WORKBASE_URL"
fi

# c++ samples
#ghq get bareflank/static_interface_pattern
#ghq get skypjack/entt
#ghq get microsoft/proxy
#ghq get foonathan/type_safe
#ghq get mpusz/mp-units
#ghq get cpp-best-practices/gui_starter_template

# Autosar samples
#ghq get inniyah/arccore
