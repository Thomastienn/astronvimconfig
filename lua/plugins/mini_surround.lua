return {
  "echasnovski/mini.surround",
  version = false, -- latest commit
  event = "VeryLazy", -- lazy-load on startup
  opts = {
    -- You can override default mappings here if you want
    mappings = {
      add = "<space>sra", -- Add surrounding
      delete = "<space>srd", -- Delete surrounding
      replace = "<space>srr", -- Replace surrounding
      find = "<space>srf", -- Find surrounding (to the right)
      find_left = "<space>srF", -- Find to the left
      highlight = "<space>srh", -- Highlight surrounding
      update_n_lines = "<space>srn", -- Update surrounding lines
    },
    custom_surroundings = {
      ["("] = { output = { left = "(", right = ")" } },
      [")"] = { output = { left = "(", right = ")" } },
      ["{"] = { output = { left = "{", right = "}" } },
      ["}"] = { output = { left = "{", right = "}" } },
      ["["] = { output = { left = "[", right = "]" } },
      ["]"] = { output = { left = "[", right = "]" } },
      ['"'] = { output = { left = '"', right = '"' } },
      ["'"] = { output = { left = "'", right = "'" } },
      ["`"] = { output = { left = "`", right = "`" } },
      ["$"] = { output = { left = "$", right = "$" } },
      ["<"] = { output = { left = "<", right = ">" } },
      [">"] = { output = { left = "<", right = ">" } },
    },
  },
}
