return {
  "benlubas/molten-nvim",
  build = ":UpdateRemotePlugins",
  version="^1.9.2",
  ft = { "python", "r", "julia" },
  config = function()
    vim.g.molten_image_provider = "image.nvim"
    vim.g.molten_use_border_highlights = true
    vim.g.molten_auto_image_popup = false
    vim.g.molten_auto_open_output = false
    vim.g.molten_virt_text_output = true
    vim.g.molten_output_show_more = true
    vim.g.molten_wrap_output = true
    vim.g.molten_tick_rate = 500

    -- Regex pattern (not vim regex)
    local custom_marker = '^# %%\\s*$'  -- matches lines that are exactly "# %%", possibly with trailing spaces

    local function skip_newline(start, end_l)
      for line_num = end_l, start, -1 do
        local line_content = vim.fn.getline(line_num)
        if not line_content:match("^%s*$") then
          return line_num
        end
      end
      return start
    end

    -- Helper function: get all cell ranges, optionally starting from a line
    local function get_cell_ranges(start_line_override)
      local buf = 0
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local markers = {}

      -- find marker lines
      for i, line in ipairs(lines) do
        if vim.fn.match(line, custom_marker) ~= -1 then
          table.insert(markers, i)
        end
      end

      if #markers == 0 then
        vim.notify('Molten: no markers found', vim.log.levels.INFO)
        return {}
      end

      local ranges = {}
      for i = 1, #markers do
        local start_line = markers[i]
        local end_line = (markers[i + 1] and markers[i + 1] - 1) or #lines

        -- If start_line_override is set, skip cells that end before the cursor
        if start_line_override and end_line < start_line_override then
          goto continue
        end

        if end_line < start_line then end_line = start_line end
        end_line = skip_newline(start_line, end_line)

        -- Skip invalid ranges where end is before or at start
        if end_line <= start_line then
          goto continue
        end

        table.insert(ranges, { start_line, end_line })
        ::continue::
      end

      return ranges
    end

    -- Core runner function
    local function run_ranges(ranges)
      if #ranges == 0 then return end
      local delay_ms = 80

      local function run_idx(idx)
        if idx > #ranges then
          vim.notify(string.format('Molten: finished %d cells', #ranges), vim.log.levels.INFO)
          return
        end
        local r = ranges[idx]
        pcall(vim.fn.MoltenEvaluateRange, r[1], r[2])
        vim.defer_fn(function() run_idx(idx + 1) end, delay_ms)
      end

      run_idx(1)
    end

    -- Run all # %% cells sequentially using MoltenEvaluateRange
    vim.keymap.set('n', '<leader>mtra', function()
      local ranges = get_cell_ranges()
      run_ranges(ranges)
    end, { desc = 'Run all cells' })

    vim.keymap.set('n', '<leader>mtrd', function()
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]  -- get current line (1-indexed)
      local ranges = get_cell_ranges(cursor_line)
      run_ranges(ranges)
    end, { desc = 'Run all cells from cursor' })

    vim.keymap.set('n', '<leader>mtm', "<cmd>MoltenImagePopup<CR>", { desc = 'Image popup' })

    vim.keymap.set('n', '<leader>mtrc', function()
      local start_line = vim.fn.search(custom_marker, 'bn')  -- Search backward for start marker
      local end_line = vim.fn.search(custom_marker, 'n')     -- Search forward for next marker

      if start_line > 0 then
        if end_line <= start_line then
          end_line = vim.fn.line('$') + 1 -- If no next marker, go to end of file
        else
          end_line = end_line - 1 -- Adjust to be inclusive
        end

        end_line = skip_newline(start_line, end_line - 1)
        -- Execute the selected range
        vim.fn.MoltenEvaluateRange(start_line, end_line)
      else
        vim.notify('Molten: No cell marker found above cursor', vim.log.levels.WARN)
      end
    end, { desc = 'Execute current cell' })

    vim.keymap.set("n", "<leader>mtt", ":MoltenInit python3<CR>", { silent = true, desc = "Initialize molten" })
    vim.keymap.set(
      "n",
      "<leader>mtre",
      ":MoltenEvaluateOperator<CR>",
      { silent = true, desc = "Run operator selection" }
    )
    vim.keymap.set("n", "<leader>mtrl", ":MoltenEvaluateLine<CR>", { silent = true, desc = "Evaluate line" })
    vim.keymap.set("n", "<leader>mtrr", ":MoltenReevaluateCell<CR>", { silent = true, desc = "Re-evaluate cell" })
    vim.keymap.set(
      "v",
      "<leader>mtr",
      ":<C-u>MoltenEvaluateVisual<CR>gv",
      { silent = true, desc = "Evaluate visual selection" }
    )
    vim.keymap.set("n", "<leader>mtd", ":MoltenDelete<CR>", { silent = true, desc = "Molten delete cell" })
    vim.keymap.set("n", "<leader>mth", ":MoltenHideOutput<CR>", { silent = true, desc = "Hide output" })
    vim.keymap.set(
      "n",
      "<leader>mto",
      ":noautocmd MoltenEnterOutput<CR>",
      { silent = true, desc = "Show/enter output" }
    )
    vim.keymap.set("n", "<leader>mti", ":MoltenInterrupt<CR>")
  end,
}
