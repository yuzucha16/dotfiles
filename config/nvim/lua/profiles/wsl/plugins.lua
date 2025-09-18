-- =====================================================================
--  Plugins for terminal (WSL) Neovim — match user's current setup
--  Manager: lazy.nvim (auto bootstrap)
-- =====================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- 基盤
  { "nvim-lua/plenary.nvim" },

  -- ctags/タグビュー
  { "preservim/tagbar" },
  { "ludovicchabant/vim-gutentags",
    init = function()
      local is_win = (vim.fn.has("win32") == 1)
      local cache_dir = is_win
        and ((vim.env.USERPROFILE or "") .. "\\.cache\\tags")
        or  (vim.fn.expand("~/.cache/tags"))
      vim.g.gutentags_project_root = { ".git", ".hg", ".svn", "compile_commands.json" }
      vim.g.gutentags_cache_dir = cache_dir
      vim.g.gutentags_ctags_executable = "ctags"
      vim.g.gutentags_modules = { "ctags" }
      vim.g.gutentags_add_default_project_roots = 0
    end
  },

  -- Telescope（+ file-browser + fzf-native）
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local t = require("telescope")
      t.setup({
        defaults = {
          sorting_strategy = "ascending",
          layout_strategy = "bottom_pane",
          layout_config = { height = 0.5, preview_width = 0.65 },
          preview = { hide_on_startup = true },
        },
        pickers = {
          lsp_workspace_symbols = { fname_width = 60, symbol_width = 60 },
        },
      })
      pcall(t.load_extension, "file_browser")
      pcall(t.load_extension, "fzf")
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- Git
  { "tpope/vim-fugitive" },
  { "lewis6991/gitsigns.nvim", opts = {} },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
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

  -- LSP / CMP（snippet 使わない簡易構成）
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function() end }, -- snippet不要
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
        }),
        sources = { { name = "nvim_lsp" }, { name = "path" }, { name = "buffer" } },
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lsp = require("lspconfig")
      local caps = require("cmp_nvim_lsp").default_capabilities()

      -- あなたの clangd オプションを反映
      lsp.clangd.setup({
        cmd = {
          "clangd", "--background-index", "--clang-tidy", "--header-insertion=never",
          "--completion-style=detailed",
          "--query-driver=/usr/bin/arm-none-eabi-*,/opt/gcc-arm*/bin/arm-none-eabi-*",
        },
        capabilities = caps,
      })

      -- 診断の見え方（あなたの設定に揃える）
      vim.diagnostic.config({
        virtual_text = false, signs = true, underline = true,
        severity_sort = true, update_in_insert = false
      })
      vim.keymap.set("n","gl", vim.diagnostic.open_float, { desc="Line diagnostics" })

      -- LSP のバッファローカルキーは profiles/wsl/keymaps.lua の LspAttach で設定
    end
  },

  -- UI
  { "nvim-tree/nvim-web-devicons" },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          show_close_icon = false,
          show_buffer_close_icons = false,
          always_show_bufferline = true,
          separator_style = "thin",
        },
      })
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function eol_label()
        local ff = vim.bo.fileformat
        if ff == "dos" then return "CR+LF"
        elseif ff == "unix" then return "LF"
        elseif ff == "mac" then return "CR" else return ff end
      end
      local function enc_label()
        local fenc = vim.bo.fileencoding
        local enc  = (fenc ~= "" and fenc or vim.o.encoding)
        return string.upper(enc)
      end
      vim.o.laststatus = 3
      vim.o.showmode = false
      require("lualine").setup({
        options = {
          theme = "auto",
          globalstatus = true,
          icons_enabled = true,
          component_separators = { left = "│", right = "│" },
          section_separators   = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", { "diagnostics", sources = { "nvim_lsp" } } },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { enc_label, eol_label, "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        shell = "bash",      -- 必要なら zsh 等に変更
        direction = "float",
      })
      -- <leader>t のキーマップは keymaps.lua 側で設定
    end,
  },

  -- Colors
  { "jacoborus/tender.vim",     lazy = true  },
  { "sainnhe/everforest",       lazy = true  },
  { "sainnhe/gruvbox-material", lazy = false,
    init = function()
      -- 起動時にあなたのデフォルト配色を適用（失敗しても落ちない）
      pcall(vim.cmd.colorscheme, "gruvbox-material")
    end
  },
}, {
  ui = { border = "rounded" },
  change_detection = { notify = false },
})

-- Markdown CSS（あなたの設定を踏襲）
do
  local root = vim.env.GHQ_ROOT
  if root and root ~= "" then
    local screen_css = root .. "/github.com/jasonm23/markdown-css-themes/screen.css"
    -- local aaa_css    = root .. "/github.com/pxlrbt/markdown-css/markdown.css"
    vim.g.mkdp_markdown_css = screen_css
  end
end
