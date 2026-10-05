#!/usr/bin/env bash
set -eu

# set current setting
source ~/.profile
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# workbase (shared knowledge repo): clone straight into the vault top, outside ghq
# (a link to a ghq path is not followed by Grep/Glob/rg).
# WSL: the Windows side (scripts\windows\50_repos.bat) clones it into C:\vault\notes\resources, shared via /mnt/c.
: "${WORKBASE_URL:=https://github.com/yuzucha16/workbase}"
NOTES="$(notes_dir)"
if is_wsl; then
  if [[ -d "$NOTES/resources/.git" ]]; then
    echo "[SKIP] workbase already cloned (Windows side): $NOTES/resources"
  else
    echo "[WARN] WSL: run scripts\\windows\\50_repos.bat on Windows to clone workbase into $NOTES/resources"
  fi
else
  clone_workbase "$NOTES" "$WORKBASE_URL"
fi

# c++ samples
ghq get bareflank/static_interface_pattern
ghq get skypjack/entt
#ghq get microsoft/proxy
#ghq get foonathan/type_safe
#ghq get mpusz/mp-units
#ghq get cpp-best-practices/gui_starter_template

# Autosar samples
#ghq get inniyah/arccore
