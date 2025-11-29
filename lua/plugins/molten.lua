return {
  "benlubas/molten-nvim",
  build = ":UpdateRemotePlugins",
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
    local custom_marker = '^# %%.*$'  -- matches lines that are  "# %%", possibly with more text after

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
      local delay_ms = 200

      local function run_idx(idx)
        if idx > #ranges then
          vim.notify(string.format('Molten: finished %d cells', #ranges), vim.log.levels.INFO)
          return
        end
        local r = ranges[idx]
        local suc, err = pcall(vim.fn.MoltenEvaluateRange, r[1], r[2])
        if not suc then
          vim.notify(string.format('Molten: error running cell %d: %s', idx, err), vim.log.levels.ERROR)
          return
        end
        vim.defer_fn(function() run_idx(idx + 1) end, delay_ms)
      end

      run_idx(1)
    end

    -- Run all # %% cells sequentially using MoltenEvaluateRange
    vim.keymap.set('n', '<leader>mtra', function()
      local ranges = get_cell_ranges()
      run_ranges(ranges)
    end, { desc = 'Run all cells' })

    vim.keymap.set('n', '<leader>mte', function()
      -- Get all cells
      local buf = 0
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local markers = {}

      -- Find marker lines
      for i, line in ipairs(lines) do
        if vim.fn.match(line, custom_marker) ~= -1 then
          table.insert(markers, i)
        end
      end

      if #markers == 0 then
        vim.notify('Molten: no markers found to export', vim.log.levels.WARN)
        return
      end

      -- Build cells array
      local cells = {}
      for i = 1, #markers do
        local start_line = markers[i]
        local end_line = (markers[i + 1] and markers[i + 1] - 1) or #lines

        -- Get cell content (excluding the marker line itself)
        local cell_lines = {}
        for j = start_line + 1, end_line do
          table.insert(cell_lines, lines[j])
        end

        -- Create Jupyter cell structure
        table.insert(cells, {
          cell_type = "code",
          execution_count = vim.NIL,  -- JSON null
          metadata = {},
          outputs = {},
          source = cell_lines
        })
      end

      -- Create Jupyter notebook structure
      local notebook = {
        cells = cells,
        metadata = {
          kernelspec = {
            display_name = "Python 3",
            language = "python",
            name = "python3"
          },
          language_info = {
            name = "python",
            version = "3.0.0"
          }
        },
        nbformat = 4,
        nbformat_minor = 5
      }

      -- Convert to JSON
      local json_str = vim.fn.json_encode(notebook)

      -- Get output filename from current file
      local current_file = vim.api.nvim_buf_get_name(buf)
      local filename = current_file:match("(.+)%..+$") or "notebook"
      filename = filename .. ".ipynb"

      -- Write file asynchronously
      local uv = vim.loop or vim.uv
      uv.fs_open(filename, "w", 438, function(err_open, fd)
        if err_open then
          vim.schedule(function()
            vim.notify('Molten: failed to open file: ' .. err_open, vim.log.levels.ERROR)
          end)
          return
        end

        uv.fs_write(fd, json_str, -1, function(err_write)
          uv.fs_close(fd, function() end)

          vim.schedule(function()
            if err_write then
              vim.notify('Molten: failed to write file: ' .. err_write, vim.log.levels.ERROR)
            else
              vim.notify(string.format('Molten: exported %d cells to %s', #cells, filename), vim.log.levels.INFO)
            end
          end)
        end)
      end)
    end, { desc = 'Export to jupyter notebook' })

    vim.keymap.set('n', '<leader>mtrd', function()
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]  -- get current line (1-indexed)
      local ranges = get_cell_ranges(cursor_line)
      run_ranges(ranges)
    end, { desc = 'Run all cells from cursor' })

    vim.keymap.set('n', '<leader>mtru', function()
      local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
      local all_ranges = get_cell_ranges()

      -- Filter to only include cells that start at or before cursor
      local ranges = {}
      for _, range in ipairs(all_ranges) do
        if range[1] <= cursor_line then
          table.insert(ranges, range)
        end
      end

      run_ranges(ranges)
    end, { desc = 'Run all cells top to cursor' })

    vim.keymap.set('n', '<leader>mtm', "<cmd>MoltenImagePopup<CR>", { desc = 'Image popup' })

    vim.keymap.set('n', '<leader>mtrc', function()
      local start_line = vim.fn.search(custom_marker, 'bn')  -- Search backward for start marker
      local end_line = vim.fn.search(custom_marker, 'n')     -- Search forward for next marker

      if start_line > 0 then
        if end_line <= start_line then
          end_line = vim.fn.line('$') -- If no next marker, go to end of file
        else
          end_line = end_line - 1 -- Adjust to be inclusive
        end

        end_line = skip_newline(start_line, end_line)
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
