-- Minimal Neovim base (light first; merge parts of old LazyVim/AstroNvim configs later).
vim.g.mapleader = ' '
local o = vim.opt
o.number = true
o.relativenumber = false
o.ignorecase = true
o.smartcase = true
o.termguicolors = true
o.splitright = true
o.splitbelow = true
o.undofile = true
o.updatetime = 300
o.signcolumn = 'no'
o.wrap = true
o.linebreak = true
o.clipboard = ''

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { 'ellisonleao/gruvbox.nvim', priority = 1000, config = function() vim.cmd.colorscheme 'gruvbox' end },
  {
    -- file explorer: edit the directory as a buffer
    'stevearc/oil.nvim',
    opts = { view_options = { show_hidden = true } },
    keys = {
      { '<leader>e', '<cmd>Oil<cr>', desc = 'File explorer (cwd of current file)' },
      { '-', '<cmd>Oil<cr>', desc = 'Parent directory' },
      { '<leader>E', function() require('oil').open(vim.fn.getcwd()) end, desc = 'File explorer (cwd)' },
    },
    lazy = false,
  },
}, { rocks = { enabled = false }, change_detection = { notify = false } })

-- Markdown: wrap-friendly
vim.api.nvim_create_autocmd('FileType', { pattern = 'markdown', callback = function() vim.wo.conceallevel = 2 end })
