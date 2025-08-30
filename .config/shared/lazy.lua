-- Lazy.nvim bootstrap と薄いラッパ
local M = {}

function M.bootstrap()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({"git","clone","--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git","--branch=stable",lazypath})
  end
  vim.opt.rtp:prepend(lazypath)
end

function M.setup(spec)
  require("lazy").setup(spec, {
    ui = { border = "rounded" },
    change_detection = { notify = false },
  })
end

return M
