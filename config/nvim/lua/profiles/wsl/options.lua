-- =====================================================================
--  Options for terminal (WSL) Neovim (full power)
-- =====================================================================

local o = vim.opt
o.number         = true
o.relativenumber = true
o.signcolumn     = "yes"
o.termguicolors  = true
o.cursorline     = true
o.expandtab      = true
o.shiftwidth     = 4
o.tabstop        = 4
o.smartindent    = true
o.ignorecase     = true
o.smartcase      = true
o.wrap           = false
o.splitright     = true
o.splitbelow     = true
o.updatetime     = 200
o.timeoutlen     = 400

-- Clipboard: let your WSL environment decide; VSCode handles clipboard itself
