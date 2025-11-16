-- Disable for now
if true then return {} end

return {
  "wfxr/minimap.vim",
  build = "cargo install --locked code-minimap",
  config = function()
    -- Basic minimap settings
    vim.g.minimap_auto_start = 1
    vim.g.minimap_auto_start_win_enter = 1
    vim.g.minimap_width = 12
    vim.g.minimap_highlight_range = 1
    vim.g.minimap_highlight_search = 1
    vim.g.minimap_background_processing = 1
    vim.g.minimap_git_colors = 1
    vim.g.minimap_base_highlight = "Normal"

    -- Block minimap for certain filetypes (extend defaults)
    vim.g.minimap_block_filetypes = { "fugitive", "nerdtree", "tagbar", "fzf", "neo-tree", "NvimTree" }
    vim.g.minimap_close_filetypes = { "startify", "netrw", "vim-plug", "help", "terminal" }

    -- Color group assignments (using default group names from docs)
    vim.g.minimap_cursor_color = "minimapCursor"
    vim.g.minimap_range_color = "minimapRange"
    vim.g.minimap_search_color = "Search"
    vim.g.minimap_diffadd_color = "minimapDiffAdded"
    vim.g.minimap_diffremove_color = "minimapDiffRemoved"
    vim.g.minimap_diff_color = "minimapDiffLine"

    -- Cursor colors over git changes
    vim.g.minimap_cursor_diffadd_color = "minimapCursorDiffAdded"
    vim.g.minimap_cursor_diffremove_color = "minimapCursorDiffRemoved"
    vim.g.minimap_cursor_diff_color = "minimapCursorDiffLine"

    -- Range colors over git changes
    vim.g.minimap_range_diffadd_color = "minimapRangeDiffAdded"
    vim.g.minimap_range_diffremove_color = "minimapRangeDiffRemoved"
    vim.g.minimap_range_diff_color = "minimapRangeDiffLine"

    -- Priority settings (search > cursor > git)
    vim.g.minimap_search_color_priority = 120
    vim.g.minimap_cursor_color_priority = 110

    -- Define custom highlight groups for light theme compatibility
    local function setup_minimap_colors()
      -- Light theme compatible colors
      vim.api.nvim_set_hl(0, "minimapCursor", {
        fg = "#D2691E",
        bg = "#DCD7BA",
        bold = true,
      })

      vim.api.nvim_set_hl(0, "minimapRange", {
        fg = "#2563EB",
        bg = "#DCD7BA",
      })

      -- Git diff colors for light background
      vim.api.nvim_set_hl(0, "minimapDiffAdded", {
        -- fg = "#166534",
        fg = "#16A085",
        bg = "#DCD7BA",
        bold = true,
      })

      vim.api.nvim_set_hl(0, "minimapDiffRemoved", {
        fg = "#DC2626",
        bg = "#DCD7BA",
        bold = true,
      })

      vim.api.nvim_set_hl(0, "minimapDiffLine", {
        fg = "#3730A3",
        bg = "#DCD7BA",
        bold = true,
      })

      -- Cursor over git changes (brighter colors)
      vim.api.nvim_set_hl(0, "minimapCursorDiffAdded", {
        fg = "#16A085",
        bg = "#DCD7BA",
        bold = true,
      })

      vim.api.nvim_set_hl(0, "minimapCursorDiffRemoved", {
        fg = "#E74C3C",
        bg = "#DCD7BA",
        bold = true,
      })

      vim.api.nvim_set_hl(0, "minimapCursorDiffLine", {
        fg = "#5DADE2",
        bg = "#DCD7BA",
        bold = true,
      })

      -- Range over git changes (subtle highlight)
      vim.api.nvim_set_hl(0, "minimapRangeDiffAdded", {
        fg = "#27AE60",
        bg = "#DCD7BA",
      })

      vim.api.nvim_set_hl(0, "minimapRangeDiffRemoved", {
        fg = "#E67E22",
        bg = "#DCD7BA",
      })

      vim.api.nvim_set_hl(0, "minimapRangeDiffLine", {
        fg = "#85C1E9",
        bg = "#DCD7BA",
      })
    end

    -- Apply colors on colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = setup_minimap_colors,
    })

    -- Apply colors immediately
    vim.schedule(setup_minimap_colors)

    -- Keymaps
    vim.keymap.set("n", "<leader>mm", "<cmd>silent! MinimapToggle<CR>", { desc = "Toggle Minimap" })
    vim.keymap.set("n", "<leader>mr", "<cmd>silent! MinimapRefresh<CR>", { desc = "Refresh Minimap" })
    vim.keymap.set("n", "<leader>mc", "<cmd>silent! MinimapClose<CR>", { desc = "Close Minimap" })
  end,
}
