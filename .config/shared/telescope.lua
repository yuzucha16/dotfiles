local M = {}

function M.setup(opts)
  local telescope = require("telescope")
  local actions      = require("telescope.actions")
  local layout_act   = require("telescope.actions.layout")
  local action_state = require("telescope.actions.state")
  local has_fb, fb   = pcall(require, "telescope._extensions.file_browser")
  local fb_actions   = has_fb and require("telescope").extensions.file_browser.actions or nil

  -- ディレクトリなら降りる／ファイルならプレビュー切替
  local function smart_l(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    local path  = entry and (entry.value or entry.path or entry.filename)
    if not path then layout_act.toggle_preview(prompt_bufnr); return end
    local stat = vim.loop.fs_stat(path)
    if stat and stat.type == "directory" then
      actions.select_default(prompt_bufnr)
    else
      layout_act.toggle_preview(prompt_bufnr)
    end
  end

  telescope.setup({
    defaults = {
      layout_strategy = "bottom_pane",
      layout_config   = { height = 0.5, preview_width = 0.65 },
      preview = { hide_on_startup = true },
      sorting_strategy = "ascending",
    },
    pickers = opts and opts.pickers or {},
    extensions = has_fb and {
      file_browser = {
        theme = "ivy",
        hijack_netrw = true,
        initial_mode = "normal",
        layout_config = { height = 0.5, preview_width = 0.65 },
        grouped = true,
        hidden = true,
        mappings = {
          ["n"] = {
            ["N"] = fb_actions.create,
            ["R"] = fb_actions.rename,
            ["C"] = fb_actions.copy,
            ["D"] = fb_actions.remove,
            ["h"] = fb_actions.goto_parent_dir,
            ["l"] = smart_l,
            ["."] = fb_actions.toggle_hidden,
            ["J"] = actions.preview_scrolling_down,
            ["K"] = actions.preview_scrolling_up,
            ["<CR>"] = actions.select_default,
            ["cd"] = function(prompt_bufnr)
              local picker = action_state.get_current_picker(prompt_bufnr)
              local cwd = picker and picker.cwd
              if cwd then actions.close(prompt_bufnr); vim.fn.chdir(cwd); print("CWD: "..cwd) end
            end,
          },
          ["i"] = {
            ["<C-w>"] = function() vim.cmd("normal vbd") end,
            ["<C-j>"] = actions.preview_scrolling_down,
            ["<C-k>"] = actions.preview_scrolling_up,
            ["<C-p>"] = layout_act.toggle_preview,
            ["<C-d>"] = function(prompt_bufnr)
              local picker = action_state.get_current_picker(prompt_bufnr)
              local cwd = picker and picker.cwd
              if cwd then actions.close(prompt_bufnr); vim.fn.chdir(cwd); print("CWD: "..cwd) end
            end,
          },
        },
      },
    } or nil,
  })

  -- 拡張ロード（あるものだけ）
  pcall(telescope.load_extension, "file_browser")
  pcall(telescope.load_extension, "fzf") -- fzf-nativeが入っていれば有効化

  -- よく使うマップ（共通）
  local t = require("telescope.builtin")
  vim.keymap.set("n","<leader>ff", t.find_files, {desc="Find files"})
  vim.keymap.set("n","<leader>fg", t.live_grep,  {desc="Live grep"})
  vim.keymap.set("n","<leader>fb", t.buffers,    {desc="Buffers"})

  -- file browser 起動
  vim.keymap.set("n", "<leader>e", function()
    if pcall(function() return require("telescope").extensions.file_browser end) then
      require("telescope").extensions.file_browser.file_browser({
        path = "%:p:h", select_buffer = true, hidden = true, layout_config = { height = 0.5 },
      })
    else
      t.find_files()
    end
  end, { desc = "File: Telescope File Browser (here)" })
end

return M
