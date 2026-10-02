-- =====================================================================
--  VSCode profile: keep plugins near-zero to avoid conflicts / overhead
--  If you really want a few pure-text helpers, add them below.
-- =====================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "tpope/vim-repeat" },
  { "echasnovski/mini.surround", version = false, config = true },
  -- { "echasnovski/mini.ai", version = false, config = true }, -- optional
  -- { "numToStr/Comment.nvim", config = true },               -- VSCodeのコメント機能で十分なら不要
}, {
  checker = { enabled = false },
})
