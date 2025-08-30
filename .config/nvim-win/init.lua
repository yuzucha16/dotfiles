require("shared.core")
require("shared.lazy").bootstrap()

require("shared.lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "preservim/tagbar" },

  -- Telescope（ビルド不要構成）
  { "nvim-telescope/telescope.nvim", version = false, dependencies = { "nvim-lua/plenary.nvim" },
    config = function() require("shared.telescope").setup() end },
  { "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" } },

  -- ctags 自動
  { "ludovicchabant/vim-gutentags",
    init = function() require("shared.gutentags").init() end },

  -- UI
  { "nvim-tree/nvim-web-devicons" },
  { "akinsho/bufferline.nvim", version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("shared.ui").setup_bufferline() end },
  { "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("shared.ui").setup_lualine(false) end },

  -- Colors
  { "jacoborus/tender.vim", lazy = true },
  { "sainnhe/everforest", lazy = true },
  { "sainnhe/gruvbox-material", lazy = false,
    config = function() require("shared.colors") end },
})

-- Tagbar / ctags キーマップ
vim.keymap.set("n","<F8>", ":TagbarToggle<CR>", { silent = true, desc="Tagbar Toggle" })
vim.keymap.set("n","gD", ":tselect <C-r><C-w><CR>", { silent = true, desc="Tag select (ctags)" })
