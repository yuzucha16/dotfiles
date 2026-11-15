-- Markdown: wrap-friendly
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function() vim.wo.conceallevel = 2 end,
})
