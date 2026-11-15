-- Weight / theme tuning. Edit here only; everything else follows.
-- Overrides without editing the file: set NVIM_THEME (theme) or NVIM_LITE=1 (lite mode) in the environment.
local M = {}

-- Theme (all dark). The other two are installed but not loaded until chosen.
--   "gruvbox-material" : default. Highlights match Zed "Material Gruvbox Dark" (lua/plugins/colorscheme.lua)
--   "iceberg"          : cocopon/iceberg.vim
--   "tender"           : jacoborus/tender.vim
-- Switch temporarily inside nvim with `:colorscheme iceberg`.
M.theme = vim.env.NVIM_THEME or "gruvbox-material"

-- Lite mode: turn off the heavier parts at once (UI extras, LSP / completion).
-- Treesitter (syntax highlighting) always stays on.
local lite = vim.env.NVIM_LITE == "1"

-- true = install / use, false = do not install. Defaults follow lite mode; change one line to tune individually.
M.plugins = {
  ["folke/noice.nvim"] = not lite, -- floating cmdline / messages (heavy UI)
  ["folke/snacks.nvim"] = true, -- LazyVim core (picker, explorer, dashboard). Do not disable
  ["nvim-lualine/lualine.nvim"] = not lite, -- statusline
  ["akinsho/bufferline.nvim"] = not lite, -- buffer tabs
  ["folke/flash.nvim"] = not lite, -- jump motions
  ["folke/trouble.nvim"] = not lite, -- diagnostics list
  ["folke/todo-comments.nvim"] = not lite,
  ["lewis6991/gitsigns.nvim"] = not lite,
  ["folke/which-key.nvim"] = true, -- key hints (light and useful, keep)
  -- LSP / completion (mason downloads servers: heaviest part)
  ["neovim/nvim-lspconfig"] = not lite,
  ["mason-org/mason.nvim"] = not lite,
  ["mason-org/mason-lspconfig.nvim"] = not lite,
  ["saghen/blink.cmp"] = not lite,
  ["stevearc/conform.nvim"] = not lite, -- formatter
  ["mfussenegger/nvim-lint"] = not lite, -- linter
}

return M
