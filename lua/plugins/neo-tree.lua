return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignore = false,
        hide_by_name = {
          ".DS_Store",
          "node_modules",
          "__pycache__",
          ".git",
          ".ropeproject",
        },
      },
      window = {
        mappings = {
          ["<BS>"] = "navigate_up", -- go up one directory
          ["<CR>"] = "set_root", -- go into selected directory
          ["<leader>so"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              -- Only open files externally, not directories
              if not node.type or node.type == "file" then
                local win_path = vim.fn.system({ "wslpath", "-w", path }):gsub("\n", "")
                vim.fn.jobstart({ "explorer.exe", win_path }, { detach = true })
              end
            end,
            desc = "Open with Windows default app (via explorer.exe)",
          },
        },
      },
    },
  },
}
