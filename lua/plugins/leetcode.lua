return {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
    dependencies = {
        -- include a picker of your choice, see picker section for more details
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    opts = {
        -- configuration goes here
        lang="python3",
    },
    keys = {
        { "<leader>lcc", "<cmd>Leet<CR>", desc = "Toggle leetcode" },
        { "<leader>lcr", "<cmd>Leet run<CR>", desc = "Run" },
        { "<leader>lcs", "<cmd>Leet submit<CR>", desc = "Submit" },
        { "<leader>lcl", "<cmd>Leet lang<CR>", desc = "Pick language" },
        { "<leader>lci", "<cmd>Leet info<CR>", desc = "Info" },
        { "<leader>lcd", "<cmd>Leet desc<CR>", desc = "Description tab" },
        { "<leader>lcy", "<cmd>Leet yank<CR>", desc = "Yank" },
    }
}
