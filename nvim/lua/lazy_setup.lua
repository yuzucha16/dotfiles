require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "^5", -- Remove version tracking to elect for nightly AstroNvim
    import = "astronvim.plugins",
    opts = { -- AstroNvim options must be set here with the `import` key
      mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
      maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
      icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
      pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
      update_notifications = true, -- Enable/disable notification about running `:Lazy update` twice to update pinned plugins
    },
  },

  -- LSP (C言語: clangd)
  { "neovim/nvim-lspconfig", config = function()
      local lspconfig = require("lspconfig")
      lspconfig.clangd.setup({
	    cmd = {
		  "clangd",
		  "--header-insertion=never",  -- 自動include候補を無効
		  "--clang-tidy=false",        -- clang-tidyを完全OFF（静的解析の抑制）
	    },
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        on_attach = function(_, bufnr)
          local map = function(keys, cmd)
            vim.api.nvim_buf_set_keymap(bufnr, "n", keys, cmd, { noremap = true, silent = true })
          end
          map("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
          map("gr", "<cmd>lua vim.lsp.buf.references()<CR>")
          map("gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
          map("K",  "<cmd>lua vim.lsp.buf.hover()<CR>")
          map("<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
        end,
      })
    end
  },

  -- 補完（cmp + LuaSnip）
  { "hrsh7th/nvim-cmp", config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },
      })
    end
  },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- neo-tree（ファイラー）
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
	    close_if_last_window = false,
		popup_border_style = "rounded",
		enable_git_status = true,
		enable_diagnostics = false,
		use_default_mappings = true,  -- ★右キーで preview を有効にする

		window = {
		  position = "left",
		  width = 30,
		  mapping_options = {
		    noremap = true,
		    nowait = true,
		  },
		  mappings = {
		    ["<cr>"] = "open",
		    ["l"] = "open",
		    ["h"] = "close_node",
		    ["<Right>"] = "open_preview",  -- ← 明示的に preview に割り当て
		  }
		},

		filesystem = {
		  filtered_items = {
		    visible = true,
		    hide_dotfiles = false,
		    hide_gitignored = false,
		  },
		}
	  })
      vim.keymap.set("n", "<C-n>", ":Neotree toggle left<CR>")
    end,
  },

  -- Telescope（ファイル検索）
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
      vim.keymap.set("n", "<leader>rf", builtin.lsp_references)
    end,
  },

  -- ステータスライン
  { "nvim-lualine/lualine.nvim", config = function()
      require("lualine").setup()
    end
  },
  
  -- Theme
  { "daschw/leaf.nvim" },
  { "sainnhe/everforest" },
  { "jacoborus/tender" },

  { import = "community" },
  { import = "plugins" },
} --[[@as LazySpec]], {
  -- Configure any other `lazy.nvim` configuration options here
  install = { colorscheme = { "astrotheme", "habamax" } },
  ui = { backdrop = 100 },
  performance = {
    rtp = {
      -- disable some rtp plugins, add more to your liking
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
} --[[@as LazyConfig]])

-- 診断メッセージの表示レベル制御（仮想テキストなど）
vim.diagnostic.config({
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },  -- HINT/INFOは表示しない
  },
  signs = true,
  underline = false,            -- 下線非表示（お好みで）
  update_in_insert = false,
})
