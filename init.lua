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
vim.o.scrolloff = 8

-- Delete
vim.keymap.del("n", "<leader>h")

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

-- Runing files
vim.keymap.set("n", "<leader>rr", function()
  local Terminal = require("toggleterm.terminal").Terminal

  -- Get full path of the current file
  local current_file = vim.fn.expand "%:p"

  -- Search upwards for Cargo.toml
  local cargo_toml = vim.fn.findfile("Cargo.toml", vim.fn.fnamemodify(current_file, ":h") .. ";")
  if cargo_toml == "" then
    print "Cargo.toml not found."
    return
  end

  -- Get the directory of Cargo.toml
  local project_root = vim.fn.fnamemodify(cargo_toml, ":h")

  -- Save current file before running
  vim.cmd "write"

  -- Create and toggle the terminal with cargo run
  local cargo_term = Terminal:new {
    cmd = "cd " .. project_root .. " && cargo run",
    direction = "float",
    close_on_exit = false,
    hidden = true,
  }

  cargo_term:toggle()
end, { desc = "Run cargo" })

vim.keymap.set("n", "<leader>rp", function()
  vim.cmd "w"
  local filename = vim.fn.expand "%"
  require("toggleterm.terminal").Terminal
    :new({ cmd = "python3 " .. filename, direction = "float", close_on_exit = false })
    :toggle()
end, { desc = "Run Python file" })

-- Compile current C++ file with g++
vim.keymap.set("n", "<leader>rcc", function()
  vim.cmd "w" -- Save the current file
  local filename = vim.fn.expand "%"
  local output = vim.fn.expand "%:r"
  local flags = "g++ -DLOCAL -std=c++17 -O2 -Wall -Wextra -Wshadow"
  local cmd = string.format("%s %s -o %s", flags, filename, output)

  require("toggleterm.terminal").Terminal:new({ cmd = cmd, direction = "float", close_on_exit = false }):toggle()
end, { desc = "Compile current C++ file" })

-- Run compiled C++ output
vim.keymap.set("n", "<leader>rcr", function()
  vim.cmd "w" -- Save the file just in case
  local file_with_ext = vim.fn.expand "%:t"
  local file_name = file_with_ext:gsub(".cpp", "")
  local output = "./" .. file_name
  require("toggleterm.terminal").Terminal:new({ cmd = output, direction = "float", close_on_exit = false }):toggle()
end, { desc = "Run compiled C++ binary" })

vim.keymap.set("n", "<leader>rjv", function()
  vim.cmd "w" -- save file
  local file = vim.fn.expand "%"
  local file_escaped = vim.fn.shellescape(file)
  local classname = vim.fn.expand "%:t:r"
  local javafx_lib = vim.fn.expand "~/javafx/javafx-sdk-21.0.7/lib"
  local is_javafx = vim.fn.search "javafx\\.application\\.Application" ~= 0

  if is_javafx then
    -- compile into package dirs under project root
    local compile_cmd = table.concat({
      "javac",
      "-d",
      ".",
      "--module-path",
      '"' .. javafx_lib .. '"',
      "--add-modules",
      "javafx.controls,javafx.fxml",
      file_escaped,
    }, " ")

    -- figure out the FQCN from src/main/java/rw/app/…/Application.java
    local proj = vim.fn.getcwd()
    local src_root = proj .. "/src/main/java/"
    local fullpath = vim.fn.expand "%:p"
    local rel = fullpath:match(src_root .. "(.*)%.java$")
    local fqcn = rel and rel:gsub("/", ".") or classname

    -- run with -cp . and fully‑qualified name
    local run_cmd = table.concat({
      "java",
      "-cp",
      ".",
      "--module-path",
      '"' .. javafx_lib .. '"',
      "--add-modules",
      "javafx.controls,javafx.fxml",
      fqcn,
    }, " ")

    vim.cmd("!" .. compile_cmd)
    vim.cmd("!" .. run_cmd)
  else
    vim.cmd("!javac " .. file_escaped)
    vim.cmd("!java " .. classname)
  end
end, { desc = "Run Java or JavaFX file" })

--vim
vim.keymap.set("v", "qq", "<Esc>", { desc = "Escape visual mode" })

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
