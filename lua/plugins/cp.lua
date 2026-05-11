-- @diagnostic disable

local languages = {
	cpp = {
		name = "C++",
		template = "~/.config/nvim/snippets/cpp/cp.cpp",
	},
	py = {
		name = "Python",
		template = "~/.config/nvim/snippets/python/cp.py",
	},
	rs = {
		name = "Rust",
		template = "~/.config/nvim/snippets/rust/cp.rs",
	},
}

local lang = "py"

local language_aliases = {
	["c++"] = "cpp",
	cc = "cpp",
	cpp = "cpp",
	cxx = "cpp",
	py = "py",
	python = "py",
	python3 = "py",
	rs = "rs",
	rust = "rs",
}

local competitest_receive_modifiers = {
	[""] = true,
	CONTEST = true,
	CWD = true,
	DATE = true,
	FEXT = true,
	GROUP = true,
	HOME = true,
	JAVA_MAIN_CLASS = true,
	JAVA_TASK_CLASS = true,
	JUDGE = true,
	MEMLIM = true,
	PROBLEM = true,
	TIMELIM = true,
	URL = true,
}

local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end

	local content = f:read("*a")
	f:close()

	return content
end

local function write_file(path, content)
	local f = io.open(path, "w")
	if not f then
		return false
	end

	f:write(content)
	f:close()

	return true
end

local function escape_literal_dollars(content)
	local escaped = {}
	local i = 1

	while i <= #content do
		local char = content:sub(i, i)
		if char ~= "$" then
			table.insert(escaped, char)
			i = i + 1
		else
			local next_char = content:sub(i + 1, i + 1)
			local close = next_char == "(" and content:find(")", i + 2, true)

			if close then
				local modifier = content:sub(i + 2, close - 1)
				if competitest_receive_modifiers[modifier] then
					table.insert(escaped, content:sub(i, close))
					i = close + 1
				else
					table.insert(escaped, "$()")
					i = i + 1
				end
			else
				table.insert(escaped, "$()")
				i = i + 1
			end
		end
	end

	return table.concat(escaped)
end

local function selected_lang()
	local lang_name = tostring(lang):lower()
	local normalized = language_aliases[lang_name] or lang_name
	if languages[normalized] then
		lang = normalized
		return normalized
	end

	vim.notify("Unknown CompetiTest language '" .. lang_name .. "', falling back to .py", vim.log.levels.WARN)
	lang = "py"
	return lang
end

local function cached_template_path(ext, template_path)
	local source_path = vim.fn.expand(template_path)
	local content = read_file(source_path)
	if not content then
		vim.notify("Missing CompetiTest template: " .. source_path, vim.log.levels.WARN)
		return template_path
	end

	local cache_dir = vim.fn.stdpath("cache") .. "/competitest/templates"
	vim.fn.mkdir(cache_dir, "p")

	local target_path = cache_dir .. "/cp." .. ext
	local escaped_content = escape_literal_dollars(content)

	if read_file(target_path) ~= escaped_content and not write_file(target_path, escaped_content) then
		vim.notify("Could not write CompetiTest template cache: " .. target_path, vim.log.levels.WARN)
		return template_path
	end

	return target_path
end

local function template_files()
	local templates = {}

	for ext, language in pairs(languages) do
		templates[ext] = cached_template_path(ext, language.template)
	end

	return templates
end

local function competitest_config()
	return {
		runner_ui = {
			interface = "popup", -- "popup" | "split"
		},

		received_files_extension = selected_lang(),

		template_file = template_files(),

		received_problems_path = "$(CWD)/$(JAVA_TASK_CLASS)/$(JAVA_TASK_CLASS).$(FEXT)",
		received_contests_directory = "$(CWD)/$(CONTEST)",

		compile_command = {
			cpp = {
				exec = "g++",
				args = {
					"-O2",
					"-std=c++20",
					"-DLOCAL",
					"-Wall",
					"-Wextra",
					"-Wshadow",
					"-fsanitize=undefined",
					"$(FNAME)",
					"-o",
					"$(FNOEXT)",
				},
			},
		},

		testcases_use_single_file = true,
		view_output_diff = true,
		evaluate_template_modifiers = true,
	}
end

local function setup_competitest()
	require("competitest").setup(competitest_config())
end

local function disable_help()
	local group = vim.api.nvim_create_augroup("CompetiTestDisableHelp", {
		clear = true,
	})

	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		group = group,
		pattern = "*.cpp",
		callback = function(args)
			if vim.lsp.inlay_hint then
				vim.lsp.inlay_hint.enable(false, {
					bufnr = args.buf,
				})
			end

			vim.cmd("silent! Copilot disable")
		end,
	})
end

return {
	"xeluxee/competitest.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},

	config = function()
		setup_competitest()

		vim.keymap.set("n", "<leader>rtl", function()
			vim.ui.select({
				{ name = languages.rs.name, ext = "rs" },
				{ name = languages.cpp.name, ext = "cpp" },
				{ name = languages.py.name, ext = "py" },
			}, {
				prompt = "Choose CompetiTest language:",
				format_item = function(item)
					return item.name .. " (." .. item.ext .. ")"
				end,
			}, function(choice)
				if not choice then
					return
				end

				lang = choice.ext
				setup_competitest()

				vim.notify(
					"CompetiTest language set to ." .. lang,
					vim.log.levels.INFO
				)
			end)
		end, {
			desc = "Change CompetiTest language",
		})

		-- Control processes:
		-- Run again a testcase by pressing R
		-- Run again all testcases by pressing <C-r>
		-- Kill the process associated with a testcase by pressing K
		-- Kill all testcase processes by pressing <C-k>

		vim.keymap.set("n", "<leader>rtt", "<cmd>CompetiTest run<CR>", {
			desc = "Toggle/Run CompetiTest",
		})

		vim.keymap.set("n", "<leader>rtu", "<cmd>CompetiTest show_ui<CR>", {
			desc = "Open CompetiTest UI",
		})

		vim.keymap.set("n", "<leader>rtd", "<cmd>CompetiTest delete_testcase<CR>", {
			desc = "Delete testcase",
		})

		vim.keymap.set("n", "<leader>rtc", "<cmd>CompetiTest run_no_compile<CR>", {
			desc = "Run no compile",
		})

		vim.keymap.set("n", "<leader>rta", "<cmd>CompetiTest add_testcase<CR>", {
			desc = "Add testcase",
		})

		vim.keymap.set("n", "<leader>rte", "<cmd>CompetiTest edit_testcase<CR>", {
			desc = "Edit testcase",
		})

		vim.keymap.set("n", "<leader>rtp", function()
			vim.cmd("CompetiTest receive problem")
			disable_help()
		end, {
			desc = "Receive problem",
		})

		vim.keymap.set("n", "<leader>rtn", function()
			vim.cmd("CompetiTest receive contest")
			disable_help()
		end, {
			desc = "Receive contest",
		})

		vim.keymap.set("n", "<leader>rtb", function()
			local filepath = vim.fn.expand("%:p:h")
			local filename = vim.fn.expand("%:t:r")
			local extension = vim.fn.expand("%:e")
			local main_file = vim.fn.expand("%:p")

			local brute_filename = filepath .. "/" .. filename .. "_brute." .. extension
			local gen_filename = filepath .. "/" .. filename .. "_gen.py"
			local bash_filename = filepath .. "/diff_" .. filename .. ".sh"

			local template_dir = vim.fn.expand("~/.config/nvim/snippets/")
			local bash_template = template_dir .. "bash/diff.sh"
			local gen_template = template_dir .. "python/brute/gen.py"

			os.execute("cp " .. vim.fn.shellescape(main_file) .. " " .. vim.fn.shellescape(brute_filename))

			local gen_content = read_file(gen_template)
			if gen_content then
				write_file(gen_filename, gen_content)
			else
				write_file(gen_filename, "")
			end

			local bash_content = read_file(bash_template)
			if not bash_content then
				vim.notify("Error: missing " .. bash_template, vim.log.levels.ERROR)
				return
			end

			bash_content = bash_content:gsub("{{DIR}}", filepath)
			bash_content = bash_content:gsub("{{MAIN}}", main_file)
			bash_content = bash_content:gsub("{{BRUTE}}", brute_filename)
			bash_content = bash_content:gsub("{{GEN}}", gen_filename)

			write_file(bash_filename, bash_content)
			os.execute("chmod +x " .. vim.fn.shellescape(bash_filename))

			vim.notify(
				"Created: "
					.. brute_filename
					.. ", "
					.. gen_filename
					.. ", "
					.. bash_filename,
				vim.log.levels.INFO
			)
		end, {
			desc = "Brute force and diff",
		})
	end,
}
