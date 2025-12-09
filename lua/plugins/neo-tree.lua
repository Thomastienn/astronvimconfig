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
          ["z"] = "close_all_nodes",
          ["Z"] = "expand_all_nodes",
          ["c"] = "expand_all_subnodes",
          ['C'] = 'close_all_subnodes',
          ["<leader>so"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              -- Only open files externally, not directories
              if not node.type or node.type == "file" then
                local is_wsl = vim.fn.has("wsl") == 1
                if is_wsl then
                  local win_path = vim.fn.system({ "wslpath", "-w", path }):gsub("\n", "")
                  vim.fn.jobstart({ "explorer.exe", win_path }, { detach = true })
                else
                  vim.fn.jobstart({ "xdg-open", path }, { detach = true })
                end
              end
            end,
            desc = "Open with default app",
          },
          ["<leader>se"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node.path or vim.fn.expand "%:p"
              -- If the node is a file, get its parent directory
              if node.type == "file" then
                path = vim.fn.fnamemodify(path, ":h")
              end

              local is_wsl = vim.fn.has("wsl") == 1
              if is_wsl then
                local win_path = vim.fn.system({ "wslpath", "-w", path }):gsub("\n", "")
                vim.fn.jobstart({ "explorer.exe", win_path }, { detach = true })
              else
                vim.fn.jobstart({ "xdg-open", path }, { detach = true })
              end
            end,
            desc = "Open directory in file explorer",
          },
        },
      },
      commands = {
        -- over write default 'delete' command to 'trash'.
        delete = function(state)
	        local inputs = require("neo-tree.ui.inputs")
	        local path = state.tree:get_node().path
	        local msg = "Are you sure you want to trash " .. path
	        inputs.confirm(msg, function(confirmed)
		        if not confirmed then return end

		        vim.fn.system { "trash", path }
		        require("neo-tree.sources.manager").refresh(state.name)
	        end)
        end,

        -- over write default 'delete_visual' command to 'trash' x n.
        delete_visual = function(state, selected_nodes)
	        local inputs = require("neo-tree.ui.inputs")

	        -- get table items count
	        function GetTableLen(tbl)
		        local len = 0
		        for _ in pairs(tbl) do
			        len = len + 1
		        end
		        return len
	        end

	        local count = GetTableLen(selected_nodes)
	        local msg = "Are you sure you want to trash " .. count .. " files ?"
	        inputs.confirm(msg, function(confirmed)
		        if not confirmed then return end
		        for _, node in ipairs(selected_nodes) do
			        vim.fn.system { "trash", node.path }
		        end
		        require("neo-tree.sources.manager").refresh(state.name)
	        end)
        end,
      }
    },
  },
}
