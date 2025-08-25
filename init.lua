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

local run_file = require("run_file").run_file
vim.keymap.set("n", "<leader>rp", run_file, { desc = "Run file" })

-- Typst
vim.keymap.set("n", "<leader>pt", "<cmd>TypstPreviewToggle<CR>", { desc = "Toggle typst preview" })
local export_types = { "pdf", "png", "svg", "html" }

local function export(args)
    local target
    if vim.tbl_contains(export_types, args[1]) then
        target = args[1]
    elseif args[1] == nil then
        target = "pdf"
    else
        print "Unsupported filetype. Use 'pdf' or 'png'."
        return
    end
    local filetype = vim.bo.filetype
    if filetype ~= "typst" then
        print "Current buffer is not a typst file"
        return
    end
    local current_file = vim.fn.expand "%:p"
    local cmd = "typst compile --format " .. target .. " " .. current_file
    print("Running: " .. cmd)
    local result = vim.fn.system(cmd)
    local exit_code = vim.v.shell_error
    if exit_code ~= 0 then
        print("Typst compilation failed: " .. result)
    else
        print("Successfully exported to " .. target)
    end
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
            attach_mappings = function(_, map)
                actions.select_default:replace(function()
                    actions.close()
                    local selection = action_state.get_selected_entry()[1]
                    vim.cmd("Export " .. selection)
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

-- Compile current C++ file with g++
vim.keymap.set("n", "<leader>rcc", function()
    vim.cmd "w" -- Save the current file
    local filename = vim.fn.expand "%"
    local output = vim.fn.expand "%:r"
    local flags = "g++ -DLOCAL -std=c++17 -O2 -Wall -Wextra -Wshadow"
    local cmd = string.format("%s %s -o %s", flags, filename, output)

    require("toggleterm.terminal").Terminal:new({ cmd = cmd, direction = "float", close_on_exit = false }):toggle()
end, { desc = "Compile current C++ file" })

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
