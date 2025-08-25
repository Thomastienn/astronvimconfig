return {
  {
    "RaafatTurki/hex.nvim",
    dependencies = {},  -- no dependencies listed
    config = function()
      require("hex").setup({
        -- Optional custom config; defaults shown:
        dump_cmd = 'xxd -g 1 -u',
        assemble_cmd = 'xxd -r',
        is_file_binary_pre_read = function() return false end,
        is_file_binary_post_read = function() return false end,
      })
    end,
  },
}

