-- =====================================================================
--  Keymaps for terminal (WSL) Neovim — match user's current setup
-- =====================================================================

local map = function(mode, lhs, rhs, opts)
  opts = opts or {}; if opts.silent == nil then opts.silent = true end
  if opts.noremap == nil then opts.noremap = true end
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ===== Tagbar / ctags =====
map("n","<F8>", ":TagbarToggle<CR>", { desc = "Tagbar Toggle" })
map("n","gD",  ":tselect <C-r><C-w><CR>", { desc = "Tag select (ctags)" })

-- ===== Telescope 基本操作（util.setup_telescope 相当の主要部） =====
local ok_tb, tb = pcall(require, "telescope.builtin")
if ok_tb then
  map("n","<leader>ff", tb.find_files, { desc = "Find files" })
  map("n","<leader>fg", tb.live_grep,  { desc = "Live grep" })
  map("n","<leader>fb", tb.buffers,    { desc = "Buffers" })

  -- LSP×Telescope の補助
  map("n","<leader>sn", function() tb.lsp_workspace_symbols({ query='@namespace' }) end,
    { desc = "Symbols: Namespace" })
  map("n","<leader>sc", function() tb.lsp_workspace_symbols({ query='@class' }) end,
    { desc = "Symbols: Class" })
  map("n","<leader>sf", function() tb.lsp_workspace_symbols({ query='@function' }) end,
    { desc = "Symbols: Function" })
  map("n","<leader>ss", tb.lsp_workspace_symbols, { desc = "Symbols: Any" })
  map("n","<leader>sd", tb.lsp_document_symbols,  { desc = "Symbols: Document" })

  -- <leader>e : file-browser（無ければ find_files にフォールバック）
  map("n","<leader>e", function()
    local ok = pcall(function() return require("telescope").extensions.file_browser end)
    if ok then
      require("telescope").extensions.file_browser.file_browser({
        path = "%:p:h", select_buffer = true, hidden = true,
        layout_config = { height = 0.5, preview_width = 0.65 },
      })
    else
      tb.find_files()
    end
  end, { desc = "File: Telescope File Browser (here)" })
end

-- ===== Git: fugitive =====
map("n", "<leader>gs", ":Git<CR>",                       { desc = "Git status (fugitive)" })
map("n", "<leader>ga", ":Git add %<CR>",                 { desc = "Git add current file" })
map("n", "<leader>gc", ":Git commit<CR>",                { desc = "Git commit" })
map("n", "<leader>gp", ":Git push<CR>",                  { desc = "Git push" })
map("n", "<leader>gx", ":Git switch ",                   { desc = "Git switch branch" })
map("n", "<leader>gl", ":Git log --oneline --graph<CR>", { desc = "Git log oneline" })

-- ===== Git: gitsigns（nil 安全） =====
local function with_gs(name)
  return function(...)
    local ok, gs = pcall(require, "gitsigns")
    if not ok or type(gs[name]) ~= "function" then return end
    -- pcall の第1引数に関数、その後に可変長引数を渡す
    pcall(gs[name], ...)
  end
end
map("n", "]h", with_gs("next_hunk"),  { desc = "Next hunk" })
map("n", "[h", with_gs("prev_hunk"),  { desc = "Prev hunk" })
map("n", "<leader>hs", with_gs("stage_hunk"),  { desc = "Stage hunk" })
map("n", "<leader>hr", with_gs("reset_hunk"),  { desc = "Reset hunk" })
map("n", "<leader>hp", with_gs("preview_hunk"),{ desc = "Preview hunk" })
map("n", "<leader>hb", function()
  pcall(function() require("gitsigns").blame_line({ full = true }) end)
end, { desc = "Blame line (full)" })

-- ===== ToggleTerm =====
map("n", "<leader>t", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })

-- ===== LSP キーバインド（バッファローカル） =====
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local function bmap(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, desc = desc })
    end
    bmap("gd", vim.lsp.buf.definition,        "Goto definition")
    bmap("gr", vim.lsp.buf.references,        "References")
    bmap("gI", vim.lsp.buf.implementation,    "Implementation")
    bmap("K",  vim.lsp.buf.hover,             "Hover")
    bmap("<leader>rn", vim.lsp.buf.rename,    "Rename")
    bmap("<leader>ca", vim.lsp.buf.code_action, "Code Action")
    bmap("[d", vim.diagnostic.goto_prev,      "Diag prev")
    bmap("]d", vim.diagnostic.goto_next,      "Diag next")
  end,
})

-- ===== Bufferline （あなたの util 相当） =====
map("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>")
map("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>")
map("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>")
map("n", "<leader>l", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<leader>h", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
map("n", "<leader>bd","<Cmd>bdelete<CR>",             { desc = "Close buffer" })
