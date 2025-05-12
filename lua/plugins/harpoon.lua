return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2", -- IMPORTANT: use the new branch
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" }, -- required by Harpoon 2
  config = function()
    local harpoon = require "harpoon"
    harpoon:setup()
  end,
}
