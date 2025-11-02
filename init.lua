-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
end

require "lazy_setup"
require "polish"

-- vim.api.nvim_create_autocmd({ "User" }, {
--   pattern = "MiniMapUpdated",
--   callback = function()
--     -- Enhanced contrast minimap base with more visible text
--     vim.api.nvim_set_hl(0, "MyMinimapBase", { fg = "#C0C0C0", bg = "#1A1A1A" })
--     vim.g.minimap_base_highlight = "MyMinimapBase"
--
--     -- Bright yellow cursor with dark background for high contrast
--     vim.api.nvim_set_hl(0, "minimapCursor", { fg = "#000000", bg = "#FFFF00", bold = true })
--
--     -- More vibrant diff colors with higher contrast
--     vim.api.nvim_set_hl(0, "minimapDiffAdded", { fg = "#00FF00", bold = true })
--     vim.api.nvim_set_hl(0, "minimapDiffRemoved", { fg = "#FF0000", bold = true })
--     vim.api.nvim_set_hl(0, "minimapDiffChanged", { fg = "#FFAA00", bold = true })
--
--     -- Cursor on diff lines with high contrast
--     vim.api.nvim_set_hl(0, "minimapCursorDiffAdded", { fg = "#000000", bg = "#00FF00", bold = true })
--     vim.api.nvim_set_hl(0, "minimapCursorDiffRemoved", { fg = "#FFFFFF", bg = "#FF0000", bold = true })
--     vim.api.nvim_set_hl(0, "minimapCursorDiffChanged", { fg = "#000000", bg = "#FFAA00", bold = true })
--
--     -- Additional highlights for better visibility
--     vim.api.nvim_set_hl(0, "minimapRange", { fg = "#FFFFFF", bg = "#404040", bold = true })
--     vim.api.nvim_set_hl(0, "minimapCurrentLine", { fg = "#FFFFFF", bg = "#333333", bold = true })
--   end,
-- })

-- Neo tree
vim.api.nvim_create_user_command("OpenInExplorer", function()
    local node = require("neo-tree.sources.manager").get_state("filesystem").tree:get_node()
    local path = node.path or vim.fn.expand "%:p"

    -- If the node is a file, get its parent directory
    if node.type == "file" then path = vim.fn.fnamemodify(path, ":h") end

    local cmd = "explorer.exe $(wslpath -w " .. path .. ")"
    vim.fn.system(cmd)
end, {})
vim.api.nvim_set_keymap("n", "<leader>se", ":OpenInExplorer<CR>", { noremap = true, silent = true })

-- Overwrite default
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })
vim.o.scrolloff = 4

-- Delete
vim.keymap.del("n", "<leader>h")

-- Restart LSP
vim.keymap.set("n", "<leader>lt", function() vim.cmd "LspRestart" end, { desc = "Restart LSP" })

-- Fixing telescope
vim.keymap.set(
    "n",
    "<leader>fa",
    function()
        require("telescope.builtin").find_files {
            cwd = vim.fn.stdpath "config",
        }
    end,
    { desc = "Find config files" }
)

vim.keymap.set("n", "s", "<Nop>", { noremap = true, silent = true })

-- Typst
vim.keymap.set("n", "<leader>pt", "<cmd>TypstPreviewToggle<CR>", { desc = "Toggle typst preview" })
local export_types = { "pdf", "png", "svg", "html" }

local function export(args)
    local target
    args = args.args
    if vim.tbl_contains(export_types, args) then
        target = args
    elseif args == nil then
        target = "pdf"
    else
        vim.notify("Unsupported filetype. Use 'pdf' or 'png'.", vim.log.levels.ERROR)
        return
    end
    local filetype = vim.bo.filetype
    if filetype ~= "typst" then
        vim.notify("Current buffer is not a typst file", vim.log.levels.ERROR)
        return
    end
    local flags = ""
    if target == "html" then
        flags = " --features "
    else
        flags = " --format "
    end

    local current_file = vim.fn.expand "%:p"
    local cmd = "typst compile" .. flags .. target .. " " .. current_file
    vim.notify("Running: " .. cmd)

    vim.fn.jobstart(cmd, {
        on_exit = function(_, exit_code)
            if exit_code ~= 0 then
                vim.schedule(function()
                    vim.notify("Typst compilation failed", vim.log.levels.ERROR)
                end)
            else
                vim.schedule(function()
                    vim.notify("Successfully exported to " .. target)
                end)
            end
        end,
    })
end

vim.api.nvim_create_user_command("Export", export, {
    nargs = "?",
    complete = function() return export_types end,
})

local function export_with_picker()
    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"
    local conf = require("telescope.config").values

    pickers
        .new({}, {
            prompt_title = "Typst Export Format",
            finder = finders.new_table {
                results = export_types,
            },
            sorter = conf.generic_sorter {},
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if selection and selection.value then
                        vim.cmd("Export " .. selection.value)
                    end
                end)
                return true
            end,
        })
        :find()
end

vim.keymap.set("n", "<leader>pe", function() export_with_picker() end, { desc = "Export Typst" })

local function export_picker()
    local filetype = vim.bo.filetype
    if filetype ~= "typst" then
        print "Current buffer is not a typst file"
        return
    end

    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"

    pickers
        .new({}, {
            prompt_title = "Select Export Format",
            finder = finders.new_table {
                results = export_types,
            },
            sorter = conf.generic_sorter {},
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    export { selection.value }
                end)
                return true
            end,
        })
        :find()
end

vim.api.nvim_create_user_command("ExportPicker", export_picker, {})


-- run_file keymaps
-- Compile current C/C++ file with g++
vim.keymap.set("n", "<leader>rcc", function()
    require("run_file").compile_file()
end, { desc = "Compile current file" })
-- Compile and run current C/C++ file with g++
vim.keymap.set("n", "<leader>rcp", function()
    local function callback(cmd, opts_params_to_run)
        require("run_file").run_file(cmd, opts_params_to_run)
    end
    require("run_file").compile_only(callback)
end, { desc = "Compile and Run current file" })
-- Run current file
vim.keymap.set("n", "<leader>rp", require("run_file").run_file, { desc = "Run file" })
vim.keymap.set("n", "<leader>rd", require("run_file").debug_file, { desc = "Debug executables" })


--vim
vim.keymap.set("v", "q", "<Esc>", { desc = "Escape visual mode" })

-- refractoring keymap
vim.keymap.set("x", "<leader>re", ":Refactor extract ")
vim.keymap.set("x", "<leader>rf", ":Refactor extract_to_file ")
vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ")
vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var")
vim.keymap.set("n", "<leader>rI", ":Refactor inline_func")
vim.keymap.set("n", "<leader>rb", ":Refactor extract_block")
vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file")

-- telescope keybind overwritten
vim.keymap.set("n", "grr", "<cmd>Telescope lsp_references<CR>", { desc = "LSP References" })
vim.keymap.set("n", "gD", vim.lsp.buf.definition, { desc = "Go to definition (no Telescope)" })

-- codenium keymap
-- vim.keymap.set("i", "<C-g>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
-- github copilot keymap
vim.keymap.set("i", "<C-g>", 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false,
})
vim.g.copilot_no_tab_map = true

-- neogit
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<CR>", { desc = "Open Neogit" })

-- molten
vim.g.molten_auto_image_popup = true
vim.g.molten_image_provider = "image.nvim"

-- harpoon
local harpoon = require "harpoon"

-- Add current file to the list
vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add file" })

-- Show quick menu
vim.keymap.set(
    "n",
    "<leader>hm",
    function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
    { desc = "Harpoon quick menu" }
)

-- Navigate to specific files
vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })

-- Next file
vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Harpoon next file" })

-- Previous file
vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Harpoon previous file" })

-- Function to preview image with viu in floating terminal
local Terminal = require("toggleterm.terminal").Terminal
local image_term = nil
vim.api.nvim_set_keymap('t', 'jj', [[<C-\><C-n>]], {noremap = true, silent = true})

local function preview_image_with_viu(path)
    if not path or path == "" then
        print "No image path provided"
        return
    end

    local cmd = "viu " .. vim.fn.shellescape(path)

    image_term = Terminal:new {
        cmd = cmd,
        direction = "float",
        close_on_exit = false,
        hidden = true,
    }

    image_term:toggle()
end

vim.keymap.set("n", "<leader>rm", function()
    local path = vim.fn.expand "%:p"
    local ext = path:match "^.+(%..+)$"
    local image_extensions = { ".png", ".jpg", ".jpeg", ".bmp", ".gif", ".webp" }
    local is_image = false
    for _, e in ipairs(image_extensions) do
        if e == ext then
            is_image = true
            break
        end
    end
    if is_image then
        preview_image_with_viu(path)
    else
        print "Current file is not an image"
    end
end, { noremap = true, silent = true, desc = "Preview image with viu" })
-- End of image preview function

vim.o.fileformat = "dos" -- Set file format to DOS (CRLF) for compatibility with Windows

vim.keymap.set("n", "<leader>hx", "<cmd>silent! HexToggle<CR>", { desc = "Toggle Hex view" })

-- Debugger
require("debugger")

-- Keymaps 
-- utils
local function feedkeys(seq)
  local keys = vim.api.nvim_replace_termcodes(seq, true, false, true)
  -- 'n' = non-recursive, false = don't remap; true for "typed" behaviour is OK here
  vim.api.nvim_feedkeys(keys, 'n', true)
end

-- selection helper: create buffer-local mappings for the filetypes we care about
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "latex", "markdown", "md", "typst" },
  callback = function(ev)
    local opts = { noremap = true, silent = true, buffer = ev.buf }

    -- operator-pending: run normal! sequence (works after c/d/y)
    -- T$vt$   => go to previous '$' (T$), start visual (v), go to before next '$' (t$)
    vim.keymap.set("o", "i$", ":<C-u>normal! T$vt$<CR>", opts)
    vim.keymap.set("o", "a$", ":<C-u>normal! F$vf$<CR>", opts)

    -- visual: we are already in visual mode so DO NOT replay 'v'
    -- inner:  T$t$  (go to previous $, then go to before next $)
    -- around: F$f$  (go to previous $, then go to next $ (on the $ itself))
    vim.keymap.set("x", "i$", function() feedkeys("T$t$") end, opts)
    vim.keymap.set("x", "a$", function() feedkeys("F$f$") end, opts)
  end,
})


-- Markdown preview
vim.keymap.set("n", "<leader>md", "<cmd>Markview toggle<CR>", { desc = "Toggle markdown preview" })

if vim.env.SSH_CONNECTION then
    vim.notify("OSC52 enabled (SSH detected)", vim.log.levels.INFO)
    require('osc52').setup()
end

-- Leetcode
vim.keymap.set("n", "<leader>lcc", "<cmd>Leet<CR>", { desc = "Toggle leetcode" })
vim.keymap.set("n", "<leader>lcr", "<cmd>Leet run<CR>", { desc = "Leetcode run" })
vim.keymap.set("n", "<leader>lcs", "<cmd>Leet submit<CR>", { desc = "Leetcode submit" })
vim.keymap.set("n", "<leader>lcl", "<cmd>Leet lang<CR>", { desc = "Leetcode pick language" })
vim.keymap.set("n", "<leader>lci", "<cmd>Leet info<CR>", { desc = "Leetcode info question" })
vim.keymap.set("n", "<leader>lcd", "<cmd>Leet desc<CR>", { desc = "Leetcode description question" })

-- Competitive Programming (CP)
-- Control processes
-- Run again a testcase by pressing R
-- Run again all testcases by pressing <C-r>
-- Kill the process associated with a testcase by pressing K
-- Kill all the processes associated with testcases by pressing <C-k>
vim.keymap.set("n", "<leader>rtt", "<cmd>CompetiTest run<CR>", { desc = "Toggle/Run competitest" })
vim.keymap.set("n", "<leader>rtd", "<cmd>CompetiTest delete_testcase<CR>", { desc = "Delete testcase" })
vim.keymap.set("n", "<leader>rtc", "<cmd>CompetiTest run_no_compile<CR>", { desc = "Run no compile" })
vim.keymap.set("n", "<leader>rta", "<cmd>CompetiTest add_testcase<CR>", { desc = "Add testcase" })
vim.keymap.set("n", "<leader>rte", "<cmd>CompetiTest edit_testcase<CR>", { desc = "Edit testcase" })

vim.g.python3_host_prog = "/home/linuxbrew/.linuxbrew/bin/python3"
