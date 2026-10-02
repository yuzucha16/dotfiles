-- =====================================================================
--  Entry point: decide profile (vscode / wsl), then load 3-layer config
-- =====================================================================

-- Optional: speed up module loader (Neovim 0.9+)
pcall(function() vim.loader.enable() end)

-- 1) Decide profile only HERE (the single place with a conditional)
local profile
if vim.g.vscode == 1 then
  profile = "vscode"
else
  -- Prefer WSL for your setup; if you also run native Windows nvim, replace as needed:
  -- if vim.fn.has("wsl") == 1 then profile = "wsl" else profile = "win" end
  profile = "wsl"
end

-- 2) Shared thin layer (no env-specific stuff)
require("shared.util")
require("shared.keymaps")

-- 3) Profile-specific layers (options / plugins / keymaps)
require("profiles." .. profile .. ".options")
require("profiles." .. profile .. ".plugins")
require("profiles." .. profile .. ".keymaps")

-- 4) Local overrides (optional, ignored if not present)
pcall(require, "local.override")
