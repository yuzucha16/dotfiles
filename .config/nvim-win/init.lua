-- ===== Minimal Neovim for Code Reading (Windows/Light) =====
if vim.loader and vim.loader.enable then vim.loader.enable() end

-- ビルトイン/プロバイダ無効化（起動I/O削減）
for _, p in ipairs({
  "gzip","zip","zipPlugin","tar","tarPlugin","tohtml","tutor",
  "getscript","getscriptPlugin","vimball","vimballPlugin",
  "2html_plugin","matchit","matchparen",
  "netrw","netrwPlugin","netrwSettings","netrwFileHandlers",
  "rplugin",
}) do vim.g["loaded_"..p] = 1 end
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
-- vim.g.loaded_python3_provider = 0 -- Python3使わないなら有効化

-- 0) leader
vim.g.mapleader = " "

-- 1) lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({"git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git","--branch=stable",lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- 2) 基本UI
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.termguicolors = true
vim.opt.updatetime = 250
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 8
vim.opt.cursorline = true
vim.opt.showtabline = 2
vim.opt.fileformat = "unix"
vim.opt.fileformats = { "unix", "dos" }

-- 3) プラグイン（ビルド不要のみ／LSP/Treesitterなし）
require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "preservim/tagbar" },

  -- ctags 自動生成（軽量リーディング向け）
  {
    "ludovicchabant/vim-gutentags",
    init = function()
      vim.g.gutentags_project_root = { ".git", ".hg", ".svn", "compile_commands.json" }
      vim.g.gutentags_cache_dir = (vim.env.USERPROFILE or "") .. "\\.cache\\tags"
      vim.g.gutentags_ctags_executable = "ctags"
      vim.g.gutentags_modules = { "ctags" }
      vim.g.gutentags_add_default_project_roots = 0
    end,
  },

  -- ファジー検索（fzf-native はビルド必要なので不採用）
  { "nvim-telescope/telescope.nvim", version = false, dependencies = {"nvim-lua/plenary.nvim"},
    config = function()
      local t = require("telescope.builtin")
      vim.keymap.set("n","<leader>ff", t.find_files, {desc="Find files"})
      vim.keymap.set("n","<leader>fg", t.live_grep,  {desc="Live grep"})
      vim.keymap.set("n","<leader>fb", t.buffers,    {desc="Buffers"})
      -- LSP 連携は無し（Windows軽量）
    end
  },

  -- ファイラ（netrw 無効化済み。ビルド不要）
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      local telescope    = require("telescope")
      local fb_actions   = telescope.extensions.file_browser.actions
      local actions      = require("telescope.actions")
      local layout_act   = require("telescope.actions.layout")
      local action_state = require("telescope.actions.state")

      local function smart_l(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        local path = entry and (entry.value or entry.path or entry.filename)
        if not path then
          layout_act.toggle_preview(prompt_bufnr)
          return
        end
        local stat = vim.loop.fs_stat(path)
        if stat and stat.type == "directory" then
          actions.select_default(prompt_bufnr)
        else
          layout_act.toggle_preview(prompt_bufnr)
        end
      end

      local function set_cwd_to_browser_dir(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local cwd = picker and picker.cwd
        if cwd then
          require("telescope.actions").close(prompt_bufnr)
          vim.fn.chdir(cwd)
          print("CWD changed to: " .. cwd)
        else
          print("No CWD found from file browser.")
        end
      end

      telescope.setup({
        defaults = {
          layout_strategy = "bottom_pane",
          layout_config = { height = 0.5, preview_width = 0.65, },
          preview = { hide_on_startup = true },
          sorting_strategy = "ascending",
        },
        extensions = {
          file_browser = {
            theme = "ivy",
            hijack_netrw = true,
            initial_mode = "normal",
            layout_config = { height = 0.5, preview_width = 0.65, },
            grouped = true,
            hidden = true,
            mappings = {
              ["n"] = {
                ["N"] = fb_actions.create,
                ["R"] = fb_actions.rename,
                ["C"] = fb_actions.copy,
                ["D"] = fb_actions.remove,
                ["h"] = fb_actions.goto_parent_dir,
                ["l"] = smart_l,
                ["."] = fb_actions.toggle_hidden,
                ["J"] = actions.preview_scrolling_down,
                ["K"] = actions.preview_scrolling_up,
                ["<CR>"] = actions.select_default,
                ["cd"] = set_cwd_to_browser_dir,
              },
              ["i"] = {
                ["<C-w>"] = function() vim.cmd("normal vbd") end,
                ["<C-j>"] = actions.preview_scrolling_down,
                ["<C-k>"] = actions.preview_scrolling_up,
                ["<C-p>"] = layout_act.toggle_preview,
                ["<C-d>"] = set_cwd_to_browser_dir,
              },
            },
          },
        },
      })
      telescope.load_extension("file_browser")
      vim.keymap.set("n", "<leader>e", function()
        telescope.extensions.file_browser.file_browser({
          path = "%:p:h", select_buffer = true, hidden = true,
          layout_config = { height = 0.5 },
        })
      end, { desc = "File: Telescope File Browser (here)" })
    end,
  },

  -- タブ/ステータスライン/アイコン
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp", -- LSP無でも表示は動作可
          show_close_icon = false,
          show_buffer_close_icons = false,
          always_show_bufferline = true,
          separator_style = "thin",
        },
      })
      vim.keymap.set("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>")
      vim.keymap.set("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>")
      vim.keymap.set("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>")
      vim.keymap.set("n", "<leader>l", "<Cmd>BufferLineCycleNext<CR>",  { desc = "Next buffer" })
      vim.keymap.set("n", "<leader>h", "<Cmd>BufferLineCyclePrev<CR>",  { desc = "Prev buffer" })
      vim.keymap.set("n", "<leader>bd", "<Cmd>bdelete<CR>",              { desc = "Close buffer" })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function eol_label()
        local ff = vim.bo.fileformat
        if ff == "dos"  then return "CR+LF"
        elseif ff == "unix" then return "LF"
        elseif ff == "mac"  then return "CR"
        else return ff end
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
          disabled_filetypes = { "alpha", "dashboard", "neo-tree", "NvimTree" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { enc_label, eol_label, "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Colorscheme
  { "nvim-tree/nvim-web-devicons" },
  { "jacoborus/tender.vim", lazy = true },
  { "sainnhe/everforest", lazy = true },
  { "sainnhe/gruvbox-material", lazy = true },
})

vim.o.tags = "tags;,"   -- ctags: 親方向に "tags" を探索

-- 4) 快適ショートカット
vim.keymap.set("n","<leader>qq", ":q<CR>")
vim.keymap.set("n","<leader>ww", ":w<CR>")

-- Tagbar / ctags ショートカット
vim.keymap.set("n","<F8>", ":TagbarToggle<CR>", { silent = true, desc="Tagbar Toggle" })
vim.keymap.set("n","gD", ":tselect <C-r><C-w><CR>", { silent = true, desc="Tag select (ctags)" })

-- GUI（Goneovim/Neovide）でのみ適用
if vim.fn.has("gui_running") == 1 or vim.g.goneovim then
  vim.opt.guifont = "MyricaMMonospace Nerd Font:h9"
  pcall(function() vim.opt.linespace = 2 end)
end

vim.cmd[[colorscheme gruvbox-material]]

