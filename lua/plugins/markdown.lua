-- For `plugins/markview.lua` users.
return {
    "OXY2DEV/markview.nvim",
    lazy = false,

    -- For `nvim-treesitter` users.
    priority = 49,

    -- For blink.cmp's completion
    -- source
    -- dependencies = {
    --     "saghen/blink.cmp"
    -- },
    config = function()
        vim.keymap.set("n", "<leader>md", "<cmd>Markview toggle<CR>", { desc = "Toggle markdown preview" })
    end
,
}
