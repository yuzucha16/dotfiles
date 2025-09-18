local M = {}

-- ===== lazy.nvim bootstrap =====
local function fs_stat(path)
  -- Neovim 0.10+: vim.uv / それ以前: vim.loop
  local uv = vim.uv or vim.loop
  return uv and uv.fs_stat(path) or nil
end

function M.lazy_bootstrap()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not fs_stat(lazypath) then
    vim.fn.system({
      "git", "clone", "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    })
  end
  vim.opt.rtp:prepend(lazypath)
end

---@param spec table|fun()|string list  -- lazy.setup の第一引数と同じ
---@param opts table|nil
function M.lazy_setup(spec, opts)
  require("lazy").setup(spec, vim.tbl_deep_extend("force", {
    ui = { border = "rounded" },
    change_detection = { notify = false },
  }, opts or {}))
end

----------------------------------------------------------------
-- 0. ヘルパ（安全に require する）
----------------------------------------------------------------
local function prequire(mod)
  local ok, lib = pcall(require, mod)
  return ok and lib or nil
end

----------------------------------------------------------------
-- Core（基本オプション・Leader・共通挙動）
----------------------------------------------------------------
local function setup_core()
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "
  vim.opt.number = true
  vim.opt.relativenumber = false
  vim.opt.mouse = "a"
  vim.opt.updatetime = 200
  vim.opt.signcolumn = "yes"
  -- ここに shared/core.lua の設定を順に移植
end

----------------------------------------------------------------
-- UI（配色や見た目）
----------------------------------------------------------------
local function setup_ui()
  -- colorscheme はプラグイン依存なら pcall で守る
  local ok = pcall(vim.cmd.colorscheme, "habamax")
  if not ok then vim.notify("colorscheme not found", vim.log.levels.WARN) end
  -- ここに shared/color.lua 等の設定を移植
end

----------------------------------------------------------------
-- Keymaps（基本キーマップ）
----------------------------------------------------------------
local function setup_keys()
  local map  = vim.keymap.set
  local opts = { noremap = true, silent = true }

  map("n", "<leader>w", "<cmd>write<cr>",  vim.tbl_extend("force", opts, { desc = "Write" }))
  map("n", "<leader>q", "<cmd>quit<cr>",   vim.tbl_extend("force", opts, { desc = "Quit"  }))
end


function setup_telescope(opts)
  local ok_t, telescope = pcall(require, "telescope")
  if not ok_t then return end

  local actions      = require("telescope.actions")
  local layout_act   = require("telescope.actions.layout")
  local action_state = require("telescope.actions.state")
  local uv           = vim.uv or vim.loop

  -- file_browser がある場合だけ安全に参照
  local has_fb, _ = pcall(require, "telescope._extensions.file_browser")
  local fb_actions = nil
  if has_fb then
    fb_actions = require("telescope").extensions.file_browser.actions
  end

  -- ディレクトリなら降りる／ファイルならプレビュー切替
  local function smart_l(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    local path  = entry and (entry.value or entry.path or entry.filename)
    if not path then
      layout_act.toggle_preview(prompt_bufnr)
      return
    end
    local st = uv and uv.fs_stat(path) or nil
    if st and st.type == "directory" then
      actions.select_default(prompt_bufnr)
    else
      layout_act.toggle_preview(prompt_bufnr)
    end
  end

  telescope.setup({
    defaults = {
      layout_strategy = "bottom_pane",
      layout_config   = { height = 0.5, preview_width = 0.65 },
      preview         = { hide_on_startup = true },
      sorting_strategy = "ascending",
    },
    pickers = opts and opts.pickers or {},
    extensions = has_fb and {
      file_browser = {
        theme = "ivy",
        hijack_netrw = true,
        initial_mode = "normal",
        layout_config = { height = 0.5, preview_width = 0.65 },
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
            ["cd"] = function(prompt_bufnr)
              local picker = action_state.get_current_picker(prompt_bufnr)
              local cwd = picker and picker.cwd
              if cwd then actions.close(prompt_bufnr); vim.fn.chdir(cwd); print("CWD: " .. cwd) end
            end,
          },
          ["i"] = {
            ["<C-w>"] = function() vim.cmd("normal vbd") end,
            ["<C-j>"] = actions.preview_scrolling_down,
            ["<C-k>"] = actions.preview_scrolling_up,
            ["<C-p>"] = layout_act.toggle_preview,
            ["<C-d>"] = function(prompt_bufnr)
              local picker = action_state.get_current_picker(prompt_bufnr)
              local cwd = picker and picker.cwd
              if cwd then actions.close(prompt_bufnr); vim.fn.chdir(cwd); print("CWD: " .. cwd) end
            end,
          },
        },
      },
    } or nil,
  })

  -- 拡張ロード（存在すれば）
  pcall(telescope.load_extension, "file_browser")
  pcall(telescope.load_extension, "fzf") -- telescope-fzf-native を入れていれば有効化

  -- よく使うビルトイン
  local t = require("telescope.builtin")
  vim.keymap.set("n","<leader>ff", t.find_files, {desc="Find files"})
  vim.keymap.set("n","<leader>fg", t.live_grep,  {desc="Live grep"})
  vim.keymap.set("n","<leader>fb", t.buffers,    {desc="Buffers"})

  -- <leader>? で keymap 検索（ここに統合）
  vim.keymap.set("n", "<leader>?", function()
    t.keymaps({
      layout_strategy = "cursor",
      layout_config   = { width = 0.6, height = 0.6 },
      lhs_width       = 25,
    })
  end, { desc = "Search keymaps (Telescope)" })

  -- file browser 起動（入ってなければ find_files にフォールバック）
  vim.keymap.set("n", "<leader>e", function()
    if pcall(function() return require("telescope").extensions.file_browser end) then
      require("telescope").extensions.file_browser.file_browser({
        path = "%:p:h",
        select_buffer = true,
        hidden = true,
        layout_config = { height = 0.5 },
      })
    else
      t.find_files()
    end
  end, { desc = "File: Telescope File Browser (here)" })
end


----------------------------------------------------------------
-- 5. whick key（押した時だけ薄くヒント）
----------------------------------------------------------------
-- お好みで使える薄いラッパ（desc 付き）
local function nmap(lhs, rhs, desc, opts)
  opts = opts or {}
  opts.desc = desc
  opts.silent = opts.silent ~= false
  opts.noremap = opts.noremap ~= false
  vim.keymap.set("n", lhs, rhs, opts)
end

local function setup_whichkey()
  -- which-key が無ければ何もしない
  local ok, wk = pcall(require, "which-key")
  if not ok then return end

  wk.setup({
    plugins = {
      marks = true,
      registers = true,
      spelling = { enabled = true, suggestions = 20 },
      presets = { operators = false, motions = false, text_objects = false },
    },
    win = { border = "rounded" },
    layout = { align = "center" },
    show_help = false,
  })

  -- ── グループ見出し（<leader>配下） ──────────────────────────────
  wk.add({
    --{ "<leader>f", group = "file / telescope" },
    --{ "<leader>g", group = "git" },
    --{ "<leader>l", group = "lsp" },
    --{ "<leader>b", group = "buffer" },
    --{ "<leader>w", group = "window" },
    --{ "<leader>q", group = "session/quit" },
    --{ "<leader>t", group = "telescope" },
  })

  -- ── Telescope: 代表的なキー（desc 付きだから which-key に出る） ──
  local has_telescope, _ = pcall(require, "telescope")
  if has_telescope then
    nmap("<leader>ff", "<cmd>Telescope find_files<CR>", "Find files")
    nmap("<leader>fg", "<cmd>Telescope live_grep<CR>",  "Live grep")
    nmap("<leader>fb", "<cmd>Telescope buffers<CR>",    "Buffers")
    nmap("<leader>fh", "<cmd>Telescope help_tags<CR>",  "Help tags")
    -- t配下にも置きたい場合（好みで）
    nmap("<leader>tp", "<cmd>Telescope projects<CR>",   "Projects")
  end

  -- ── Git（gitsigns があれば活かす／無くても落ちない） ───────────
  -- 「gs が nil」問題を避けるため、直接呼び出し関数でラップ
  nmap("]h", function() pcall(function() require("gitsigns").next_hunk() end) end, "Next hunk")
  nmap("[h", function() pcall(function() require("gitsigns").prev_hunk() end) end, "Prev hunk")
  nmap("<leader>gs", function() pcall(function() require("gitsigns").stage_hunk() end) end, "Stage hunk")
  nmap("<leader>gr", function() pcall(function() require("gitsigns").reset_hunk() end) end, "Reset hunk")
  nmap("<leader>gp", function() pcall(function() require("gitsigns").preview_hunk() end) end, "Preview hunk")
  nmap("<leader>gb", function() pcall(function() require("gitsigns").blame_line({ full = true }) end) end, "Blame line")
  -- fugitive 等を使うなら（インストール済み前提ならアンコメント）
  -- nmap("<leader>gg", "<cmd>Git<CR>", "Git status")

  -- ── LSP: LspAttach でバッファローカルに desc 付き割当 ──────────
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
    callback = function(args)
      local buf = args.buf
      local function bmap(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, desc = desc })
      end

      bmap("<leader>ld", vim.lsp.buf.definition,        "Definition")
      bmap("<leader>lD", vim.lsp.buf.declaration,       "Declaration")
      bmap("<leader>lr", vim.lsp.buf.references,        "References")
      bmap("<leader>li", vim.lsp.buf.implementation,    "Implementation")
      bmap("<leader>lt", vim.lsp.buf.type_definition,   "Type definition")
      bmap("<leader>lh", vim.lsp.buf.hover,             "Hover")
      bmap("<leader>ls", vim.lsp.buf.signature_help,    "Signature help")
      bmap("<leader>la", vim.lsp.buf.code_action,       "Code action")
      bmap("<leader>ln", vim.lsp.buf.rename,            "Rename")
      bmap("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")
      bmap("<leader>le", vim.diagnostic.open_float,     "Line diagnostics")
      bmap("[d",        vim.diagnostic.goto_prev,       "Prev diagnostic")
      bmap("]d",        vim.diagnostic.goto_next,       "Next diagnostic")
    end,
  })
end

local function setup_toggleterm()
  require("toggleterm").setup({
    shell = "pwsh.exe",  -- "powershell.exe" でもOK
    direction = "float",
  })
  
  vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
end

----------------------------------------------------------------
-- 6. LSP（必要ならここに集約）
----------------------------------------------------------------
local function setup_lsp()
  -- 例：
  -- local lspconfig = prequire("lspconfig")
  -- if not lspconfig then return end
  -- lspconfig.clangd.setup({ cmd = { "clangd" } })
  -- ここに shared/lsp.lua の内容を移植
end

----------------------------------------------------------------
-- Git / そのほか（必要に応じて）
----------------------------------------------------------------
local function setup_git()
  -- 例：gitsigns のキーなど（プラグイン導入済みなら）
  -- local gs = prequire("gitsigns")
  -- if not gs then return end
  -- vim.keymap.set("n", "<leader>gb", gs.blame_line, { desc = "Git blame" })
  -- ここに shared/git.lua の内容を移植
end

----------------------------------------------------------------
-- Autocmds（自動コマンド）
----------------------------------------------------------------
local function setup_autocmds()
  local aug = vim.api.nvim_create_augroup("my_shared", { clear = true })
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = aug, callback = function() pcall(vim.highlight.on_yank) end,
  })
  -- ここに shared/autocmds.lua の内容を移植
end

----------------------------------------------------------------
-- UI: Bufferline
----------------------------------------------------------------
local function setup_ui_bufferline()
  local ok, bufferline = pcall(require, "bufferline")
  if not ok then return end

  bufferline.setup({
    options = {
      mode = "buffers",
      diagnostics = "nvim_lsp",
      show_close_icon = false,
      show_buffer_close_icons = false,
      always_show_bufferline = true,
      separator_style = "thin",
    },
  })

  vim.keymap.set("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>")
  vim.keymap.set("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>")
  vim.keymap.set("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>")
  vim.keymap.set("n", "<leader>l", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
  vim.keymap.set("n", "<leader>h", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
  vim.keymap.set("n", "<leader>bd","<Cmd>bdelete<CR>",             { desc = "Close buffer" })
end

----------------------------------------------------------------
-- UI: Lualine
----------------------------------------------------------------
local function setup_ui_lualine(with_diag)
  local ok, lualine = pcall(require, "lualine")
  if not ok then return end

  local function eol_label()
    local ff = vim.bo.fileformat
    if ff == "dos" then return "CR+LF"
    elseif ff == "unix" then return "LF"
    elseif ff == "mac" then return "CR"
    else return ff end
  end

  local function enc_label()
    local fenc = vim.bo.fileencoding
    local enc  = (fenc ~= "" and fenc or vim.o.encoding)
    return string.upper(enc)
  end

  vim.o.laststatus = 3
  vim.o.showmode = false

  lualine.setup({
    options = {
      theme = "auto",
      globalstatus = true,
      icons_enabled = true,
      component_separators = { left = "│", right = "│" },
      section_separators   = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = with_diag and { "branch", "diff", { "diagnostics", sources = { "nvim_lsp" } } }
                              or { "branch", "diff" },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { enc_label, eol_label, "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  })
end

----------------------------------------------------------------
-- Gutentags（ctags 自動生成）
----------------------------------------------------------------
local function setup_gutentags()
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

----------------------------------------------------------------
-- Colorscheme
----------------------------------------------------------------
local function setup_colors()
  -- 好きなテーマをここで設定（存在しなくてもエラーにならないように pcall）
  pcall(vim.cmd.colorscheme, "gruvbox-material")
end

----------------------------------------------------------------
-- まとめ実行（順序が超重要）
----------------------------------------------------------------
function M.setup_all()
  -- 基本（依存なし）
  setup_core()
  setup_ui()
  setup_keys()

  -- 見た目・配色（配色 → UI拡張の順が無難）
  setup_colors()

  -- Telescope & キーマップ検索
  setup_telescope()

  -- “押した時だけ薄くヒント”
  setup_toggleterm()
  --setup_whichkey()

  -- UI拡張
  setup_ui_bufferline()
  setup_ui_lualine(true)  -- 診断をステータスラインに表示するなら true

  -- 開発支援
  setup_gutentags()
  setup_lsp()   -- 使うなら中身を移植して有効化
  setup_git()   -- 使うなら中身を移植して有効化

  -- 最後に自動コマンド
  setup_autocmds()
end

M.setup_telescope = setup_telescope

return M
