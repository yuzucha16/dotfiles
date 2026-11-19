# 作業ログ（log）

dotfiles の現在状態と次にやること。作業の終わりに Next Actions と Open Questions を更新し、経緯は `docs/log-history.md` の `## Log` の先頭に足す。判断の根拠・却下案・Gotchas は `docs/decisions.md`。各項の詳しい原文（2026-10-16 に縮めた前の全文）は、`docs/log-history.md` の 2026-10-16 の項にある。

## 期日（今日以前、または3日以内の項目は、最初の返答で知らせて判断を求める。書式は workbase の `workflow-kit/docs-rules.md`）

| 期日 | 種別 | 内容 | 担当 |
|---|---|---|---|
| （なし） | | | |

## Next Actions

次の番号: 9

5. 【起票 11-15】【やる:ユーザー】WezTerm + claude + nvim の動作確認: (a) `WEZTERM_CONFIG_FILE` を使わず、通常の起動（`links.map` のリンク）で左 claude・右 nvim が組まれる、(b) claude 自身の入力待ち・停止で、別タブにいるときタブに 🔔 が付く（11-15 は手で鳴らした bell だけ確認）、(c) タブ名が `wslhost.exe` のまま（直したいか）、(d) 動作確認で気づいた直しを伝える（直しは AI が行う）。完了: (a)〜(c) の結果がユーザーから報告される。
7. 【起票 11-15】【やる:AI】`scripts/windows/30_link.bat` を、Developer Mode がオフのときは何も変えずに止める（先に確認する）。完了: オフの状態で `link` を実行すると、既存のリンクを消さずに `[ERR]` で止まり、`tests/windows/` に再現の試験がある。理由: 11-15 に、既存のファイルリンクが消えて Windows Terminal の設定が初期化された（`decisions.md` の同日の項）。
8. 【起票 11-19】【やる:ユーザー】単位設計 `docs/setup/terminal-units.md` に沿って、既存の試作（`windows/wezterm/`、`home/.config/nvim/`、`docs/setup/wezterm-claude-nvim.md`）を消し、zellij・WezTerm・LazyVim を作って実機で確かめる。pane の配置は案 A（左右 2 分割）と案 B（中央 3 分割。推奨）を `default_layout` の切り替えで動かして 1 つに決める。完了: 設計書 9 章の 9 点（性能の測定 V1〜V6 は 11 章。差が出た所だけ対策する。版の揃えは 12 章。固定した表 + SHA-256 で、初期値は今の scoop の版。実装は workbase 側の別作業。先に ee が `scoop list` の結果を渡す）の結果がユーザーから報告され、設計書が結果に合わせて直る。NA 5 はこれに吸収する案（ユーザーの判断待ち）。次の一手: room で zellij の `config.kdl` と案 B のレイアウトを作る。

## Open Questions
