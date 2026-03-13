-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require "null-ls"
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- Enable and configure Prettier
      null_ls.builtins.formatting.prettier.with {
        extra_args = {
          "--tab-width",
          "4",
          "--indent-size",
          "4",
          "--use-tabs",
          "false",
          "--single-quote",
          "true",
        },
      },
      -- Configure clang_format to use 4-space indentation
      null_ls.builtins.formatting.clang_format.with {
        extra_args = {
          "--style",
          "file:" .. vim.fn.expand("~/thomas_config/lsp/.clang-format"),
        },
      },
    })
  end,
}
