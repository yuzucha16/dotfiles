-- Dark only. The chosen theme is in lua/config/features.lua (M.theme).
local theme = require("config.features").theme

-- Zed "Material Gruvbox Dark" (home/.config/zed/themes/material-gruvbox.json) syntax colors, mapped to
-- treesitter captures. Only applied to gruvbox-material; iceberg / tender keep their own palette.
local function zed_highlights()
  local c = {
    fg = "#d4be98", red = "#ea6962", orange = "#e78a4e", yellow = "#d8a657", green = "#a9b665",
    aqua = "#89b482", blue = "#7daea3", purple = "#d3869b", heading = "#a7b85a",
    grey = "#928374", punct = "#a89984",
  }
  local hl = {
    Comment = { fg = c.grey, italic = true },
    ["@comment"] = { fg = c.grey, italic = true },
    ["@comment.documentation"] = { fg = c.grey, italic = true },
    ["@attribute"] = { fg = c.blue },
    ["@boolean"] = { fg = c.purple },
    ["@constant"] = { fg = c.purple },
    ["@constant.builtin"] = { fg = c.purple },
    ["@constructor"] = { fg = c.blue },
    ["@function"] = { fg = c.green },
    ["@function.call"] = { fg = c.green },
    ["@function.method"] = { fg = c.green },
    ["@function.method.call"] = { fg = c.green },
    ["@function.builtin"] = { fg = c.green },
    ["@keyword"] = { fg = c.red },
    ["@label"] = { fg = c.blue },
    ["@number"] = { fg = c.purple },
    ["@number.float"] = { fg = c.purple },
    ["@operator"] = { fg = c.orange },
    ["@property"] = { fg = c.blue },
    ["@variable.member"] = { fg = c.blue },
    ["@punctuation"] = { fg = c.punct },
    ["@punctuation.bracket"] = { fg = c.punct },
    ["@punctuation.delimiter"] = { fg = c.punct },
    ["@punctuation.special"] = { fg = c.orange },
    ["@string"] = { fg = c.green },
    ["@string.escape"] = { fg = c.aqua },
    ["@string.regexp"] = { fg = c.aqua },
    ["@string.special"] = { fg = c.aqua },
    ["@string.special.symbol"] = { fg = c.aqua },
    ["@tag"] = { fg = c.orange },
    ["@type"] = { fg = c.yellow },
    ["@type.builtin"] = { fg = c.yellow },
    ["@variable"] = { fg = c.fg },
    ["@variable.builtin"] = { fg = c.purple },
    -- Markdown (Zed overrides: strong = normal weight, headings bold, list marker orange)
    ["@markup.heading"] = { fg = c.heading, bold = true },
    ["@markup.strong"] = { fg = c.yellow },
    ["@markup.italic"] = { fg = c.yellow, italic = true },
    ["@markup.raw"] = { fg = c.blue },
    ["@markup.link"] = { fg = c.blue },
    ["@markup.link.label"] = { fg = c.blue },
    ["@markup.link.url"] = { fg = c.aqua },
    ["@markup.list"] = { fg = c.orange },
  }
  for group, def in pairs(hl) do
    vim.api.nvim_set_hl(0, group, def)
  end
end

return {
  -- default theme: material palette, medium contrast (same family as Zed's Material Gruvbox Dark)
  {
    "sainnhe/gruvbox-material",
    lazy = theme ~= "gruvbox-material",
    priority = 1000,
    init = function()
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_foreground = "material"
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_italic = 1
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "gruvbox-material",
        group = vim.api.nvim_create_augroup("zed_highlights", { clear = true }),
        callback = zed_highlights,
      })
    end,
  },
  -- installed but not loaded until selected (lazy = true): no startup cost
  { "cocopon/iceberg.vim", lazy = theme ~= "iceberg", priority = 1000 },
  -- LazyVim's bundled themes are not used: do not install them
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },
  { "jacoborus/tender.vim", lazy = theme ~= "tender", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        vim.o.background = "dark"
        vim.cmd.colorscheme(theme)
      end,
    },
  },
}
