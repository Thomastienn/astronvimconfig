return {
  "echasnovski/mini.surround",
  version = false, -- latest commit
  event = "VeryLazy", -- lazy-load on startup
  opts = {
    -- You can override default mappings here if you want
    mappings = {
      add = "sa", -- Add surrounding
      delete = "sd", -- Delete surrounding
      replace = "sr", -- Replace surrounding
      find = "sf", -- Find surrounding (to the right)
      find_left = "sF", -- Find to the left
      highlight = "sh", -- Highlight surrounding
      update_n_lines = "sn", -- Update surrounding lines
    },
  },
}
