return {
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  keys = {
    {
      "<leader>ss",
      function() require("spectre").toggle() end,
      desc = "Toggle Spectre",
    },
    {
      "<leader>sw",
      function() require("spectre").open_visual { select_word = true } end,
      mode = "n",
      desc = "Search current word",
    },
    {
      "<leader>sw",
      function() require("spectre").open_visual() end,
      mode = "v",
      desc = "Search selected text",
    },
    {
      "<leader>sp",
      function() require("spectre").open_file_search { select_word = true } end,
      desc = "Search in current file",
    },
  },
  opts = {
    open_cmd = "vnew", -- open in vertical split
    live_update = true,
  },
}
