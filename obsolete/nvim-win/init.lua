-- init.lua (clean ver.)
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
  
  -- Telescope（ビルド不要構成）
  { "nvim-telescope/telescope.nvim", version = false, dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" } },
  -- 任意：fzfネイティブ
  -- { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- ctags 自動
  { "ludovicchabant/vim-gutentags" },

  -- UI
  { "nvim-tree/nvim-web-devicons" },
  { "akinsho/bufferline.nvim", version = "*", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Terminal
  { "akinsho/toggleterm.nvim", version = "*" },

  -- Markdown live preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()  -- Node.jsでバックエンドをインストール
    end,
  },

  -- Colors
  { "jacoborus/tender.vim",        lazy = true  },
  { "sainnhe/everforest",          lazy = true  },
  { "sainnhe/gruvbox-material",    lazy = false }, -- ← util.setup_colors() で即適用するので eager
})

-- 5) プラグイン初期化が一段落したタイミングで “一発ロード”
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    util.setup_all()
    
    -- Tagbar / ctags
    vim.keymap.set("n","<F8>", ":TagbarToggle<CR>", { silent = true, desc = "Tagbar Toggle" })
    vim.keymap.set("n","gD",  ":tselect <C-r><C-w><CR>", { silent = true, desc = "Tag select (ctags)" })

    -- Markdown
    vim.keymap.set("n", "<leader>ms", "<cmd>MarkdownPreview<CR>", { desc = "Markdown Preview Start" })
    vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Markdown Preview" })
    vim.keymap.set("n", "<leader>mx", "<cmd>MarkdownPreviewStop<CR>", { desc = "Markdown Preview Stop" })
  
    -- 4) Markdown style
    vim.g.mkdp_browser = "msedge"        -- ブラウザ指定（chrome, edge など）
    vim.g.mkdp_open_ip = "127.0.0.1"
    vim.g.mkdp_echo_preview_url = 1      -- URLをエコー出力 (コピーして他環境で開ける)

    local root = os.getenv("GHQ_ROOT")
    local screen_css= root .. "/github.com/jasonm23/markdown-css-themes/screen.css"
    local aaa_css   = root .. "/github.com/pxlrbt/markdown-css/markdown.css"
    vim.g.mkdp_markdown_css = aaa_css
  end,
})
