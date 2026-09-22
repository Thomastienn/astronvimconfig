return {
    c = {
        {
            name = "compiler",
            choices = { "cc", "gcc", "clang" },
            validate = function(value)
                return vim.fn.executable(value) == 1, "compiler not found: " .. value
            end,
        },
        {
            name = "standard",
            choices = { "c99", "c89", "c11", "c17", "c2x", "c23" },
            format_item = function(value)
                if value == "c2x" then return "c2x (C23 draft)" end
                if value == "c23" then return "c23 (requires compiler support)" end
                return value
            end,
        },
    },
}
