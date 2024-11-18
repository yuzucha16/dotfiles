-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"

-- Theme: see lua/plugins/colorscheme.lua
vim.cmd[[colorscheme tender]]

-- Option:
vim.opt.title = true
vim.opt.list = true
vim.opt.fileformats = 'dos', 'unix', 'mac'
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.ruler = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.backspace = indent, eol, start
vim.opt.display = lastline
vim.opt.showmatch = true
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.backup = false
vim.opt.clipboard:append({unnamed, autoselect})
vim.opt.mouse = 'a'
vim.opt.ignorecase = false
vim.opt.wrapscan = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.wildmenu = true
vim.opt.history=1000
vim.opt.wildmode=list,full
vim.opt.wildmode:append({list, full})
vim.opt.compatible = false
vim.opt.helplang = 'ja', 'en'
vim.opt.updatetime = 250
