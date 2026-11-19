-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- claude がファイルを書き換えたら取り込む（docs/setup/terminal-units.md 9 章の 5）。
-- zellij の pane 移動で FocusGained が来ないことがあるので、カーソルの停止時にも checktime する。
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("claude_checktime", { clear = true }),
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- 実機（2026-11-19）で、pane を移って待つだけでは CursorHold が来なかったので、一定間隔でも checktime する。
-- 未保存の編集があるバッファは、checktime が上書きか破棄かを聞く（nvim の標準の動作）。
local checktime_timer = vim.uv.new_timer()
checktime_timer:start(
  2000,
  2000,
  vim.schedule_wrap(function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("silent! checktime")
      -- 放置中は、取り込んでも画面が更新されない（バッファを選ぶと出る）ので、再描画する。
      vim.cmd("redraw")
    end
  end)
)
