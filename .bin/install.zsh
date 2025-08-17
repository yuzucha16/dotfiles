#!/usr/bin/env zsh
set -ue  # -u: 未定義変数でエラー, -e: 途中失敗で終了

helpmsg() {
  command echo "Usage: $0 [--help | -h]" 0>&2
  command echo ""
}

link_to_homedir() {
  command echo "backup old dotfiles..."
  if [ ! -d "$HOME/.dotbackup" ]; then
    command echo "$HOME/.dotbackup not found. Make it automatically"
    command mkdir "$HOME/.dotbackup"
  fi

  # zsh でのスクリプト実体の絶対パス取得（sourced でも OK）
  local script_path=${${(%):-%N}:A}
  local script_dir=${script_path:h}
  local dotdir=${script_dir:h}

  if [[ "$HOME" != "$dotdir" ]]; then
    # .??* の無マッチでエラーにしないために (N) 修飾子を付与
    for f in "$dotdir"/.??*(N); do
      # .git は除外
      [[ ${f:t} == ".git" ]] && continue

      # 既存がシンボリックリンクなら削除
      if [[ -L "$HOME/${f:t}" ]]; then
        command rm -f -- "$HOME/${f:t}"
      fi
      # 実体があるならバックアップへ退避
      if [[ -e "$HOME/${f:t}" ]]; then
        command mv -- "$HOME/${f:t}" "$HOME/.dotbackup"
      fi
      # ホーム直下へ同名でシンボリックリンク作成
      command ln -snf -- "$f" "$HOME"
    done
  else
    command echo "same install src dest"
  fi
}

# 引数処理
while [ $# -gt 0 ]; do
  case ${1} in
    --debug|-d)
      set -uex
      ;;
    --help|-h)
      helpmsg
      exit 1
      ;;
    *)
      ;;
  esac
  shift
done

link_to_homedir
git config --global include.path "~/.gitconfig_shared"
command printf '\e[1;36m Install completed!!!! \e[m\n'
