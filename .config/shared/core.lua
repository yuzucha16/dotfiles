-- 共通の軽量化＆基本UI
if vim.loader and vim.loader.enable then vim.loader.enable() end

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
-- vim.g.loaded_python3_provider = 0 -- Python3不要なら有効化

vim.g.mapleader = " "

-- 共通UI
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

-- ctags 検索パス（共通）
vim.o.tags = "tags;,"

-- 共通ショートカット
vim.keymap.set("n","<leader>qq", ":q<CR>")
vim.keymap.set("n","<leader>ww", ":w<CR>")

-- GUI調整（Goneovim/Neovideなど）
if vim.fn.has("gui_running") == 1 or vim.g.goneovim then
  vim.opt.guifont = "MyricaMMonospace Nerd Font:h9"
  pcall(function() vim.opt.linespace = 2 end)
end
