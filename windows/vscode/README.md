# VS Code

| ファイル | 内容 |
|---|---|
| `windows/vscode/settings.json` `keybindings.json` | Windows の VS Code 設定（`manifests/links.map` でリンク） |
| `manifests/vscode-extensions.win.txt` | Windows 側の拡張一覧（拡張ID、1行1件） |
| `manifests/vscode-extensions.wsl.txt` | WSL（VS Code Server）側の拡張一覧 |

## 拡張の導入（一覧 → 環境）

一覧の拡張をまとめて入れる（導入済みは `code` がスキップする）。

- Windows: `scripts\windows\21_vscode.bat`
- WSL / Linux: `scripts/linux/21_vscode.sh`

## 拡張の書き出し（環境 → 一覧）

拡張を追加・削除したら、一覧を更新してコミットする。

```powershell
# Windows
code --list-extensions > manifests\vscode-extensions.win.txt
```

```bash
# WSL
code --list-extensions > manifests/vscode-extensions.wsl.txt
```

## 補足

- 一覧にはバージョンを書かない（`--show-versions` を付けない）。
- `settings.json` では拡張の自動更新を止めている（`extensions.autoUpdate` / `extensions.autoCheckUpdates`）。
