return {
  "thesimonho/kanagawa-paper.nvim",
  lazy = false,
  priority = 1000,
  opts = {},
  config = function()
    vim.o.background = "light"
    vim.cmd.colorscheme "kanagawa-paper-canvas"
  end,
}
