# Windows for import

```powershell
Get-Content .\extensions.txt | ForEach-Object { code --install-extension $_ }
```

# WSL for import

```bash
xargs -r -n1 code --install-extension < extensions.txt
```

# common for export

```shell
code --list-extensions --show-versions > extensions.txt
```

```json
{
  "extensions.autoUpdate": false,
  "extensions.autoCheckUpdates": false
}
```

