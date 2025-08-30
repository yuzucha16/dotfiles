local M = {}

function M.setup_bufferline()
  require("bufferline").setup({
    options = {
      mode = "buffers",
      diagnostics = "nvim_lsp",
      show_close_icon = false,
      show_buffer_close_icons = false,
      always_show_bufferline = true,
      separator_style = "thin",
    },
  })
  vim.keymap.set("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>")
  vim.keymap.set("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>")
  vim.keymap.set("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>")
  vim.keymap.set("n", "<leader>l", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
  vim.keymap.set("n", "<leader>h", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
  vim.keymap.set("n", "<leader>bd","<Cmd>bdelete<CR>",             { desc = "Close buffer" })
end

function M.setup_lualine(with_diag)
  local function eol_label()
    local ff = vim.bo.fileformat
    if ff == "dos" then return "CR+LF"
    elseif ff == "unix" then return "LF"
    elseif ff == "mac" then return "CR" else return ff end
  end
  local function enc_label()
    local fenc = vim.bo.fileencoding
    local enc  = (fenc ~= "" and fenc or vim.o.encoding)
    return string.upper(enc)
  end
  vim.o.laststatus = 3
  vim.o.showmode = false

  require("lualine").setup({
    options = {
      theme = "auto",
      globalstatus = true,
      icons_enabled = true,
      component_separators = { left = "│", right = "│" },
      section_separators   = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = with_diag and { "branch", "diff", { "diagnostics", sources = { "nvim_lsp" } } }
                              or { "branch", "diff" },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { enc_label, eol_label, "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  })
end

return M
