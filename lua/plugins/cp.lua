--@diagnostic disable

return {
	'xeluxee/competitest.nvim',
	dependencies = 'MunifTanjim/nui.nvim',
	config = function()
	    require('competitest').setup({
	        runner_ui = {
	            interface = "popup" -- "popup" | "split"
	        },
	        received_files_extension = "cpp",
	        template_file = {
	        	cpp = "~/.config/nvim/snippets/cpp/cp.cpp",
 				py = "~/.config/nvim/snippets/python/cp.py",
	        },
	        received_problems_path = "$(CWD)/$(JAVA_TASK_CLASS)/$(JAVA_TASK_CLASS).$(FEXT)",
	        received_contests_directory = "$(CWD)/$(CONTEST)",
	        compile_command = {
	        	cpp = { exec = "g++", args = { "-O2", "-std=c++20", "-DLOCAL", "-Wall", "-Wextra", "-Wshadow", "-fsanitize=undefined", "$(FNAME)", "-o", "$(FNOEXT)" } },
	        },
	        testcases_use_single_file = true,
	        view_output_diff = true,
	        evaluate_template_modifiers = true,
	    })
	    local function disable_help()
			vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
				pattern = "*.cpp",
				callback = function()
					-- Disable inlay hints
					vim.lsp.inlay_hint.enable(false, { bufnr = 0 })

					-- Disable GitHub Copilot
					vim.cmd("Copilot disable")
				end,
			})
	    end
		-- Control processes
		-- Run again a testcase by pressing R
		-- Run again all testcases by pressing <C-r>
		-- Kill the process associated with a testcase by pressing K
		-- Kill all the processes associated with testcases by pressing <C-k>
		vim.keymap.set("n", "<leader>rtt", ":CompetiTest run<CR>", { desc = "Toggle/Run competitest" })
		vim.keymap.set("n", "<leader>rtu", ":CompetiTest show_ui<CR>", { desc = "Open UI" })
		vim.keymap.set("n", "<leader>rtd", ":CompetiTest delete_testcase<CR>", { desc = "Delete testcase" })
		vim.keymap.set("n", "<leader>rtc", ":CompetiTest run_no_compile<CR>", { desc = "Run no compile" })
		vim.keymap.set("n", "<leader>rta", ":CompetiTest add_testcase<CR>", { desc = "Add testcase" })
		vim.keymap.set("n", "<leader>rte", ":CompetiTest edit_testcase<CR>", { desc = "Edit testcase" })
		vim.keymap.set("n", "<leader>rtp", function()
			-- ":CompetiTest receive problem<CR>"
			vim.cmd("CompetiTest receive problem")
			disable_help()
		end, { desc = "Receive problem" })
		vim.keymap.set("n", "<leader>rtn", function()
			-- ":CompetiTest receive contest<CR>"
			vim.cmd("CompetiTest receive contest")
			disable_help()
		end, { desc = "Receive contest" })
	end,
}
