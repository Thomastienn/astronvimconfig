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
    },
  },
}
