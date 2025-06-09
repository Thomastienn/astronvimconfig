return {
  "LunarVim/bigfile.nvim",
  lazy = false, -- needed so it loads before other plugins
  opts = {
    filesize = 2,
    pattern = { "*" },
    features = {
      "indent_blankline",
      "illuminate",
      "lsp",
      "treesitter",
      "syntax",
      "matchparen",
      "vimopts",
      "filetype",
    },
  },
}
