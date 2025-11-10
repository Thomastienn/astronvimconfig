return {
  "thesimonho/kanagawa-paper.nvim",
  lazy = false,
  priority = 1000,
  init = function()
    vim.o.background = 'dark'
    vim.cmd.colorscheme("kanagawa-paper-ink")
  end,
}
