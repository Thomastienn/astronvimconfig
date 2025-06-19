return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    completions = {
      blink = { enabled = true }, -- enable blink completions
      coq = { enabled = false }, -- leave coq disabled
      lsp = { enabled = true }, -- enable lsp completions
      filter = {
        callout = function()
          -- example filter: include all callouts
          return true
        end,
        checkbox = function() return true end,
      },
    },
  },
  keys = {
    { "<leader>md", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle Markdown Preview" },
  },
}
