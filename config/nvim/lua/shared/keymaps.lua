-- =====================================================================
--  Shared key habits only (no env-specific bindings here)
--  Actual “what to run” is implemented in each profile's keymaps.lua
-- =====================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic editing UX everyone likes
local map = require("shared.util").map
map({ "n", "v" }, "H", "^")
map({ "n", "v" }, "L", "$")
map("n", "Y", "y$")

-- Better window navigation (no env-specific)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Quick save/quit (neutral)
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write" })
map("n", "<leader>q", "<cmd>quit<CR>",  { desc = "Quit" })

-- Placeholder only: actual impl in profiles/*/keymaps.lua
-- <leader>e : File explorer
-- gd/gr/rn  : LSP-like nav
-- <leader>ff,fg,fb etc : Fuzzy/grep/buffers
