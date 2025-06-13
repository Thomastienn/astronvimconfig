return {
  "dstein64/nvim-scrollview",
  config = function()
    require("scrollview").setup {
      excluded_filetypes = { "prompt", "TelescopePrompt", "noice" },
      current_only = false,
      signs = {
        -- show signs for diagnostics and git (if available)
        ["gitsigns"] = true,
        ["diagnostics"] = true,
      },
      diagnostics_severities = {
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.WARN,
        vim.diagnostic.severity.HINT,
        vim.diagnostic.severity.INFO,
      },
    }
  end,
}
