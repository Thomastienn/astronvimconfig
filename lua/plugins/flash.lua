return {
  "folke/flash.nvim",
  event = "VeryLazy",
  --- ---@type Flash.Config
  opts = {
    modes = {
      char = {
        -- Enable the backdrop effect (dimming other text)
        backdrop = true,
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "<leader>a", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "<leader>A", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "<leader>ar", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "<leader>aR", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
