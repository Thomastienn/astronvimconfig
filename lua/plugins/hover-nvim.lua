return {
  "lewis6991/hover.nvim",
  lazy = true,
  init = function()
    -- plugin expects mousemove events for mouse hover
    vim.o.mousemoveevent = true
  end,
  keys = {
    { "K",      function() require("hover").open() end,              desc = "Hover (open)" },
    { "<leader>hve",     function() require("hover").enter() end,             desc = "Hover (enter)" },
    { "<leader>hvn",     function() require("hover").switch("next") end,      desc = "Hover (next source)" },
    { "<leader>hvp",     function() require("hover").switch("previous") end,  desc = "Hover (previous source)" },
    { "<MouseMove>", function() require("hover").mouse() end,        desc = "Hover (mouse)" },
  },
  opts = {
    providers = {
      "hover.providers.diagnostic",
      "hover.providers.man",
      "hover.providers.lsp",
      "hover.providers.dap",
      "hover.providers.dictionary",
    },
    preview_opts = { border = "single" },
    preview_window = false,
    title = true,
    mouse_providers = { "hover.providers.lsp" },
    mouse_delay = 1000,
  },
}
