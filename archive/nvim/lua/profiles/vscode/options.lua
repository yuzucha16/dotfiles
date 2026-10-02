-- =====================================================================
--  Options for VSCode-backed Neovim (keep it minimal)
--  UI / LSP / FS operations are delegated to VSCode
-- =====================================================================

local o = vim.opt
o.number         = true
o.relativenumber = false  -- VSCode gutter is rich enough
o.signcolumn     = "yes"
o.termguicolors  = true
o.cursorline     = true
o.wrap           = false
o.swapfile       = false
o.updatetime     = 200
o.timeoutlen     = 400
