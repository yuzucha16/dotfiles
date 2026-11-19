-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- .vimrc から移したもの。Neovim の既定や LazyVim の既定と同じ値も、明示のため書いている。
local opt = vim.opt

-- 表示
opt.title = true
opt.number = true
opt.ruler = true
opt.showmatch = true
opt.display = "lastline"

-- インデント・編集
opt.autoindent = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.backspace = { "indent", "eol", "start" }

-- 検索
opt.incsearch = true
opt.hlsearch = true
opt.wrapscan = true
opt.ignorecase = true
opt.smartcase = true

-- コマンドライン補完
opt.wildmenu = true

-- ファイル・バッファ
opt.mouse = "a"
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.hidden = true
opt.undofile = true
