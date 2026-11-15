return {
  -- file explorer: edit the directory as a buffer
  "stevearc/oil.nvim",
  lazy = false,
  opts = { view_options = { show_hidden = true } },
  keys = {
    { "<leader>e", "<cmd>Oil<cr>", desc = "File explorer (cwd of current file)" },
    { "-", "<cmd>Oil<cr>", desc = "Parent directory" },
    { "<leader>E", function() require("oil").open(vim.fn.getcwd()) end, desc = "File explorer (cwd)" },
  },
}
