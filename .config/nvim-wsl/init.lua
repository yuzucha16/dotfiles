require("shared.core")
require("shared.lazy").bootstrap()

require("shared.lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "preservim/tagbar" },

  -- Telescope（WSLは fzf-native を有効化）
  { "nvim-telescope/telescope.nvim", version = false, dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("shared.telescope").setup({
        pickers = { lsp_workspace_symbols = { fname_width = 60, symbol_width = 60 } }
      })
    end },
  { "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" } },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- Treesitter（WSLのみ）
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c","cpp","lua","vim","vimdoc","query",
                             "markdown","markdown_inline","bash","json","yaml" },
        highlight = { enable = true },
      })
    end },

  -- LSP/CMP（WSLのみ）
  { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp","hrsh7th/cmp-buffer","hrsh7th/cmp-path" } },
  { "neovim/nvim-lspconfig",
    config = function()
      local lsp = require("lspconfig")
      lsp.clangd.setup {
        cmd = { "clangd","--background-index","--clang-tidy","--header-insertion=never",
                "--completion-style=detailed","--query-driver=/usr/bin/arm-none-eabi-*,/opt/gcc-arm*/bin/arm-none-eabi-*" },
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      }
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function() end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = { { name = "nvim_lsp" }, { name = "path" }, { name = "buffer" } },
      })
      local on_attach = function(_, bufnr)
        local map = function(m, lhs, rhs, d) vim.keymap.set(m, lhs, rhs, { buffer = bufnr, desc = d }) end
        map("n","gd", vim.lsp.buf.definition, "Goto definition")
        map("n","gr", vim.lsp.buf.references, "References")
        map("n","gI", vim.lsp.buf.implementation, "Implementation")
        map("n","K",  vim.lsp.buf.hover, "Hover")
        map("n","<leader>rn", vim.lsp.buf.rename, "Rename")
        map("n","<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("n","[d", vim.diagnostic.goto_prev, "Diag prev")
        map("n","]d", vim.diagnostic.goto_next, "Diag next")
      end
      local orig = lsp.util.default_config.on_attach
      lsp.util.default_config.on_attach = function(client, bufnr)
        if orig then orig(client, bufnr) end
        on_attach(client, bufnr)
      end
      vim.diagnostic.config({ virtual_text=false, signs=true, underline=true, severity_sort=true, update_in_insert=false })
      vim.keymap.set("n","gl", vim.diagnostic.open_float, { desc="Line diagnostics" })
    end },

  -- ctags 自動（WSLでも便利）
  { "ludovicchabant/vim-gutentags", init = function() require("shared.gutentags").init() end },

  -- UI
  { "nvim-tree/nvim-web-devicons" },
  { "akinsho/bufferline.nvim", version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("shared.ui").setup_bufferline() end },
  { "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("shared.ui").setup_lualine(true) end },

  -- Colors
  { "jacoborus/tender.vim", lazy = true },
  { "sainnhe/everforest", lazy = true },
  { "sainnhe/gruvbox-material", lazy = false,
    config = function() require("shared.colors") end },
})

-- Tagbar / ctags などの共通マップ
vim.keymap.set("n","<F8>", ":TagbarToggle<CR>", { silent = true, desc="Tagbar Toggle" })
vim.keymap.set("n","gD", ":tselect <C-r><C-w><CR>", { silent = true, desc="Tag select (ctags)" })

-- Telescope x LSP 追加（WSLのみ）
local tb = require("telescope.builtin")
vim.keymap.set('n','<leader>sn', function() tb.lsp_workspace_symbols({ query='@namespace' }) end, { desc = 'Symbols: Namespace' })
vim.keymap.set('n','<leader>sc', function() tb.lsp_workspace_symbols({ query='@class' })     end, { desc = 'Symbols: Class' })
vim.keymap.set('n','<leader>sf', function() tb.lsp_workspace_symbols({ query='@function' })  end, { desc = 'Symbols: Function' })
vim.keymap.set('n','<leader>ss', tb.lsp_workspace_symbols, { desc = 'Symbols: Any' })
vim.keymap.set('n','<leader>sd', tb.lsp_document_symbols,  { desc = 'Symbols: Document' })
