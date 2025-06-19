return {
  "benlubas/molten-nvim",
  build = ":UpdateRemotePlugins",
  init = function() 
    vim.g.molten_output_win_max_height = 20 
    -- Create augroup for molten formatting control
    vim.api.nvim_create_augroup("MoltenFormatting", { clear = true })
  end,
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
    
    -- Disable formatting when molten is active
    vim.api.nvim_create_autocmd("User", {
      pattern = "MoltenInitPost",
      group = "MoltenFormatting",
      callback = function()
        -- Disable format on save for current buffer
        vim.b.autoformat = false
        print("Molten active: Disabled autoformat for this buffer")
      end,
    })
    
    -- Re-enable formatting when molten is deinitialized
    vim.api.nvim_create_autocmd("User", {
      pattern = "MoltenDeinitPost",
      group = "MoltenFormatting", 
      callback = function()
        -- Re-enable format on save for current buffer
        vim.b.autoformat = nil
        print("Molten deactivated: Re-enabled autoformat for this buffer")
      end,
    })
    
    -- Also disable formatting for .ipynb files
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*.ipynb",
      group = "MoltenFormatting",
      callback = function()
        vim.b.autoformat = false
      end,
    })
  end,
}
