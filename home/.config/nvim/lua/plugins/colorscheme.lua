return {
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.gruvbox_material_background = "medium" -- soft | medium | hard
      vim.g.gruvbox_material_foreground = "material" -- material | mix | original
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_better_performance = 1

      -- Markdown highlights matched to Zed: heading = green, strong = orange (normal weight), code = blue
      local green, orange, blue = "#a9b665", "#e78a4e", "#7daea3"
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "gruvbox-material",
        group = vim.api.nvim_create_augroup("markdown_zed_highlights", { clear = true }),
        callback = function()
          local set = vim.api.nvim_set_hl
          for i = 1, 6 do
            set(0, "@markup.heading." .. i .. ".markdown", { fg = green, bold = true })
            set(0, "RenderMarkdownH" .. i, { fg = green, bold = true })
            set(0, "RenderMarkdownH" .. i .. "Bg", { bg = "NONE" })
          end
          set(0, "@markup.heading", { fg = green, bold = true })
          set(0, "@markup.strong", { fg = orange, bold = false })
          set(0, "@markup.raw", { fg = blue })
          set(0, "@markup.raw.markdown_inline", { fg = blue })
          set(0, "@markup.raw.block.markdown", { fg = blue })
          set(0, "@markup.list.markdown", { fg = orange })
          set(0, "RenderMarkdownCode", { bg = "NONE" })
          set(0, "RenderMarkdownCodeInline", { fg = blue })
        end,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "gruvbox-material" },
  },
}
