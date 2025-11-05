return {
  "benlubas/molten-nvim",
  build = ":UpdateRemotePlugins",
  init = function()
    vim.g.molten_output_win_max_height = 20
    vim.g.molten_image_provider = "none"
    vim.g.molten_use_border_highlights = true
    vim.g.molten_auto_image_popup = false
    vim.g.molten_auto_open_output = false
    vim.g.molten_virt_text_output = true
    vim.g.molten_virt_lines_off_by_1 = true
    vim.g.molten_output_show_more = true
    vim.g.molten_wrap_output = true
    vim.g.molten_tick_rate = 500
    -- Create augroup for molten formatting control
    vim.api.nvim_create_augroup("MoltenFormatting", { clear = true })
  end,
  ft = { "python", "r", "julia" },
  config = function()
    vim.keymap.set("n", "<leader>mtt", ":MoltenInit<CR>", { silent = true, desc = "Initialize molten" })
    vim.keymap.set(
      "n",
      "<leader>mte",
      ":MoltenEvaluateOperator<CR>",
      { silent = true, desc = "run operator selection" }
    )
    vim.keymap.set("n", "<leader>mtl", ":MoltenEvaluateLine<CR>", { silent = true, desc = "evaluate line" })
    vim.keymap.set("n", "<leader>mtr", ":MoltenReevaluateCell<CR>", { silent = true, desc = "re-evaluate cell" })
    vim.keymap.set(
      "v",
      "<leader>mtr",
      ":<C-u>MoltenEvaluateVisual<CR>gv",
      { silent = true, desc = "evaluate visual selection" }
    )
    vim.keymap.set("n", "<leader>mtd", ":MoltenDelete<CR>", { silent = true, desc = "molten delete cell" })
    vim.keymap.set("n", "<leader>mth", ":MoltenHideOutput<CR>", { silent = true, desc = "hide output" })
    vim.keymap.set(
      "n",
      "<leader>mto",
      ":noautocmd MoltenEnterOutput<CR>",
      { silent = true, desc = "show/enter output" }
    )
    vim.keymap.set("n", "<leader>mti", ":MoltenInterrupt<CR>")
  end,
}
