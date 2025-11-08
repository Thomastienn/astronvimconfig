return {
    "folke/noice.nvim",
    event = "VeryLazy",
    keys = {
        {
            "<leader>ih",
            "<cmd>Noice pick<CR>",
            desc = "Noice History",
        },
    },
    opts = {
        -- add any options here
        views = {
            cmdline_popup = {
                position = { row = 2, col = "50%" },   -- top of screen
            },
        },
        lsp = {
            hover = {
                enabled = false,
            },
            signature = {
                enabled = false,
            },
        }
    },
    dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        {
            "hrsh7th/nvim-cmp",
            dependencies = { "hrsh7th/cmp-cmdline" },
            config = function()
                local ok, cmp = pcall(require, "cmp")
                if not ok then return end
                -- setup minimal cmdline completion
                -- Not override blink too much
                if cmp.setup.cmdline then
                    pcall(function()
                        cmp.setup.cmdline(":", {
                            mapping = cmp.mapping.preset.cmdline(),
                            sources = cmp.config.sources({
                                { name = "path" },
                            }, {
                                { name = "cmdline" },
                            }),
                        })
                        cmp.setup.cmdline("/", {
                            mapping = cmp.mapping.preset.cmdline(),
                            sources = { { name = "buffer" } },
                        })
                    end)
                end
            end,
        },
    },
}
