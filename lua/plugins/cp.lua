--@diagnostic disable

return {
	'xeluxee/competitest.nvim',
	dependencies = 'MunifTanjim/nui.nvim',
	config = function()
	    require('competitest').setup({
	        runner_ui = {
	            interface = "popup" -- "popup" | "split"
	        },
	        received_files_extension = "py",
	        template_file = {
	        	cpp = "~/.config/nvim/snippets/cpp/cp.cpp",
 				py = "~/.config/nvim/snippets/python/cp.py",
	        },
	        evaluate_template_modifiers = true,
	    })
		-- Control processes
		-- Run again a testcase by pressing R
		-- Run again all testcases by pressing <C-r>
		-- Kill the process associated with a testcase by pressing K
		-- Kill all the processes associated with testcases by pressing <C-k>
		vim.keymap.set("n", "<leader>rtt", ":CompetiTest run<CR>", { desc = "Toggle/Run competitest" })
		vim.keymap.set("n", "<leader>rtd", ":CompetiTest delete_testcase<CR>", { desc = "Delete testcase" })
		vim.keymap.set("n", "<leader>rtc", ":CompetiTest run_no_compile<CR>", { desc = "Run no compile" })
		vim.keymap.set("n", "<leader>rta", ":CompetiTest add_testcase<CR>", { desc = "Add testcase" })
		vim.keymap.set("n", "<leader>rte", ":CompetiTest edit_testcase<CR>", { desc = "Edit testcase" })
	end,
}
