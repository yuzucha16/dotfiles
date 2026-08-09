-- =====================================================================
--  Keymaps for VSCode-backed Neovim
--  Bridge Neovim-style keys to VSCode commands
-- =====================================================================

local map = require("shared.util").map

local function V(cmd) vim.fn.VSCodeNotify(cmd) end

-- File explorer
map("n", "<leader>e", function() V("workbench.view.explorer") end, { desc = "Explorer (VSCode)" })

-- “Telescope-ish” bindings → VSCode native
map("n", "<leader>ff", function() V("workbench.action.quickOpen") end,         { desc = "Find Files" })
map("n", "<leader>fg", function() V("workbench.action.findInFiles") end,       { desc = "Live Grep" })
map("n", "<leader>fb", function() V("workbench.action.showAllEditors") end,    { desc = "Buffers" })
map("n", "<leader>fs", function() V("workbench.action.showAllSymbols") end,    { desc = "Workspace Symbols" })

-- LSP-like nav (delegate to VSCode)
map("n", "gd", function() V("editor.action.revealDefinition") end, { desc = "Goto Def" })
map("n", "gr", function() V("editor.action.goToReferences") end,   { desc = "Goto Refs" })
map("n", "<leader>rn", function() V("editor.action.rename") end,   { desc = "Rename" })
map("n", "K",  function() V("editor.action.showHover") end,        { desc = "Hover" })

-- Optional niceties
map({ "n", "x" }, "gc", function() V("editor.action.commentLine") end, { desc = "Toggle Comment" })
