-- =====================================================================
--  Shared util (keep it thin & environment-agnostic)
-- =====================================================================

local M = {}

-- Safe require (returns nil if missing)
function M.sr(mod)
  local ok, m = pcall(require, mod)
  if ok then return m end
  return nil
end

-- Map helper with sane defaults
function M.map(mode, lhs, rhs, opts)
  opts = opts or {}
  if opts.silent == nil then opts.silent = true end
  if opts.noremap == nil then opts.noremap = true end
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Notify helper
function M.info(msg) vim.notify(msg, vim.log.levels.INFO) end
function M.warn(msg) vim.notify(msg, vim.log.levels.WARN) end
function M.err(msg)  vim.notify(msg, vim.log.levels.ERROR) end

return M
