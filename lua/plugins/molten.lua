return {
  "benlubas/molten-nvim",
  build = ":UpdateRemotePlugins",
  init = function() vim.g.molten_output_win_max_height = 20 end,
  ft = { "python", "r", "julia" },
  config = function()
    vim.keymap.set("n", "<localleader>mi", ":MoltenInit<CR>", { silent = true, desc = "Initialize the plugin" })
    vim.keymap.set(
      "n",
      "<localleader>e",
      ":MoltenEvaluateOperator<CR>",
      { silent = true, desc = "run operator selection" }
    )
    vim.keymap.set("n", "<localleader>rl", ":MoltenEvaluateLine<CR>", { silent = true, desc = "evaluate line" })
    vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { silent = true, desc = "re-evaluate cell" })
    vim.keymap.set(
      "v",
      "<localleader>r",
      ":<C-u>MoltenEvaluateVisual<CR>gv",
      { silent = true, desc = "evaluate visual selection" }
    )
    vim.keymap.set("n", "<localleader>rd", ":MoltenDelete<CR>", { silent = true, desc = "molten delete cell" })
    vim.keymap.set("n", "<localleader>oh", ":MoltenHideOutput<CR>", { silent = true, desc = "hide output" })
    vim.keymap.set(
      "n",
      "<localleader>os",
      ":noautocmd MoltenEnterOutput<CR>",
      { silent = true, desc = "show/enter output" }
    )
    vim.keymap.set("n", "<localleader>ri", ":MoltenInterrupt<CR>")
  end,
}
