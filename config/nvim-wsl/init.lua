-- init.lua (WSL 専用 clean ver.)
local util = require("util")

-- 1) lazy.nvim を用意
util.lazy_bootstrap()

-- 2) プラグイン定義
util.lazy_setup({
  { "nvim-lua/plenary.nvim" },
  { "preservim/tagbar" },
  
  -- ショートカットヒント
  --{ "folke/which-key.nvim", event = "VeryLazy", version = false},
  --{ "echasnovski/mini.icons", version = false },

  -- Telescope（fzf-native も有効化）
  { "nvim-telescope/telescope.nvim", version = false, dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" } },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- Git 関連
  { "tpope/vim-fugitive" },
  { "lewis6991/gitsigns.nvim", opts = {} },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c","cpp","lua","vim","vimdoc","query",
          "markdown","markdown_inline","bash","json","yaml",
        },
        highlight = { enable = true },
      })
    end
  },

  -- LSP/CMP
  { "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp","hrsh7th/cmp-buffer","hrsh7th/cmp-path" },
  },
  { "neovim/nvim-lspconfig",
    config = function()
      local lsp = require("lspconfig")
      lsp.clangd.setup({
        cmd = {
          "clangd","--background-index","--clang-tidy","--header-insertion=never",
          "--completion-style=detailed",
          "--query-driver=/usr/bin/arm-none-eabi-*,/opt/gcc-arm*/bin/arm-none-eabi-*",
        },
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function() end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
        }),
        sources = { { name = "nvim_lsp" }, { name = "path" }, { name = "buffer" } },
      })
      local on_attach = function(_, bufnr)
        local map = function(m, lhs, rhs, d) vim.keymap.set(m, lhs, rhs, { buffer = bufnr, desc = d }) end
        map("n","gd", vim.lsp.buf.definition,      "Goto definition")
        map("n","gr", vim.lsp.buf.references,      "References")
        map("n","gI", vim.lsp.buf.implementation,  "Implementation")
        map("n","K",  vim.lsp.buf.hover,           "Hover")
        map("n","<leader>rn", vim.lsp.buf.rename,  "Rename")
        map("n","<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("n","[d", vim.diagnostic.goto_prev,    "Diag prev")
        map("n","]d", vim.diagnostic.goto_next,    "Diag next")
      end
      local orig = lsp.util.default_config.on_attach
      lsp.util.default_config.on_attach = function(client, bufnr)
        if orig then orig(client, bufnr) end
        on_attach(client, bufnr)
      end
      vim.diagnostic.config({
        virtual_text=false, signs=true, underline=true,
        severity_sort=true, update_in_insert=false
      })
      vim.keymap.set("n","gl", vim.diagnostic.open_float, { desc="Line diagnostics" })
    end
  },

  -- ctags 自動
  { "ludovicchabant/vim-gutentags" },

  -- UI
  { "nvim-tree/nvim-web-devicons" },
  { "akinsho/bufferline.nvim", version = "*", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        shell = "bash",       -- WSL 用。必要なら zsh 等に変更
        direction = "float",
      })
      vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
    end,
  },

  -- Colors
  { "jacoborus/tender.vim",     lazy = true  },
  { "sainnhe/everforest",       lazy = true  },
  { "sainnhe/gruvbox-material", lazy = false }, -- util.setup_colors()で適用
})

-- 3) 共通マップ（Tagbar / ctags）
vim.keymap.set("n","<F8>", ":TagbarToggle<CR>", { silent = true, desc = "Tagbar Toggle" })
vim.keymap.set("n","gD",  ":tselect <C-r><C-w><CR>", { silent = true, desc = "Tag select (ctags)" })

-- 4) Telescope x LSP の補助マップ
local ok_tb, tb = pcall(require, "telescope.builtin")
if ok_tb then
  vim.keymap.set('n','<leader>sn', function() tb.lsp_workspace_symbols({ query='@namespace' }) end, { desc = 'Symbols: Namespace' })
  vim.keymap.set('n','<leader>sc', function() tb.lsp_workspace_symbols({ query='@class' })     end, { desc = 'Symbols: Class' })
  vim.keymap.set('n','<leader>sf', function() tb.lsp_workspace_symbols({ query='@function' })  end, { desc = 'Symbols: Function' })
  vim.keymap.set('n','<leader>ss', tb.lsp_workspace_symbols, { desc = 'Symbols: Any' })
  vim.keymap.set('n','<leader>sd', tb.lsp_document_symbols,  { desc = 'Symbols: Document' })
end

-- 5) fugitive / gitsigns のキー
vim.keymap.set("n", "<leader>gs", ":Git<CR>",                        { desc = "Git status (fugitive)" })
vim.keymap.set("n", "<leader>ga", ":Git add %<CR>",                  { desc = "Git add current file" })
vim.keymap.set("n", "<leader>gc", ":Git commit<CR>",                 { desc = "Git commit" })
vim.keymap.set("n", "<leader>gp", ":Git push<CR>",                   { desc = "Git push" })
vim.keymap.set("n", "<leader>gx", ":Git switch ",                    { desc = "Git switch branch" })
vim.keymap.set("n", "<leader>gl", ":Git log --oneline --graph<CR>",  { desc = "Git log oneline" })

local gs_ok, gs = pcall(require, "gitsigns")
if gs_ok then
  vim.keymap.set("n", "]h", gs.next_hunk,                            { desc = "Next hunk" })
  vim.keymap.set("n", "[h", gs.prev_hunk,                            { desc = "Prev hunk" })
  vim.keymap.set("n", "<leader>hs", gs.stage_hunk,                   { desc = "Stage hunk" })
  vim.keymap.set("n", "<leader>hr", gs.reset_hunk,                   { desc = "Reset hunk" })
  vim.keymap.set("n", "<leader>hp", gs.preview_hunk,                 { desc = "Preview hunk" })
  vim.keymap.set("n", "<leader>hb", function() gs.blame_line({full=true}) end, { desc = "Blame line (full)" })
end

-- 6) Markdown style
local root = os.getenv("GHQ_ROOT")
local screen_css = root .. "/github.com/jasonm23/markdown-css-themes/screen.css"
local aaa_css    = root .. "/github.com/pxlrbt/markdown-css/markdown.css"
vim.g.mkdp_markdown_css = screen_css

-- 7) VeryLazy 後に “一発ロード” ＋ Telescopeのpickersを上書き
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    util.setup_all()
    if pcall(require, "telescope") then
      util.setup_telescope({
        pickers = {
          lsp_workspace_symbols = { fname_width = 60, symbol_width = 60 },
        },
      })
    end
  end,
})
