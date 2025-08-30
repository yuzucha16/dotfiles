local M = {}

function M.init()
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

return M
