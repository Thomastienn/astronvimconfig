local run = {}

-- Returns the cmd
function run.compile_only()
    local filetype = vim.bo.filetype
    -- Everytime update new language, handle extra cmd in the run_file function
    if filetype == "cpp" then
        vim.cmd "w" -- Save the current file
        local filename = vim.fn.expand "%"
        local output = vim.fn.expand "%:r"
        local flags = "g++ -DLOCAL -std=c++17 -O2 -Wall -Wextra -Wshadow"
        local cmd = string.format("%s %s -o %s", flags, filename, output)

        return cmd
    end
    if filetype == "c" then
        vim.cmd "w" -- Save the current file
        local filename = vim.fn.expand "%"
        local output = vim.fn.expand "%:r"
        local flags = "gcc"
        local cmd = string.format("%s %s -o %s", flags, filename, output)

        return cmd
    else
        return nil
    end
end

function run.compile_file()
    local cmd = run.compile_only()
    if cmd == nil then
        print("No compile command configured for filetype: " .. vim.bo.filetype)
        return
    end
    require("toggleterm.terminal").Terminal:new({ cmd = cmd, direction = "float", close_on_exit = false }):toggle()
end

local function run_java(...)
    vim.cmd "w" -- save file
    local file = vim.fn.expand "%:t"
    -- local file_escaped = vim.fn.shellescape(file)
    -- local classname = vim.fn.expand "%:t:r"
    -- vim.cmd("!javac " .. file_escaped)
    require("toggleterm.terminal").Terminal
        :new({
            cmd = "java " .. file,
            direction = "float",
            close_on_exit = false,
        })
        :toggle()
end

local function run_python(_, extra_args)
    vim.cmd "w" -- save file
    local filename = vim.fn.expand "%:p" -- full path
    local cwd = vim.fn.getcwd()
    local venv_paths = {
        cwd .. "/venv/bin/activate",
        cwd .. "/.venv/bin/activate",
    }
    local activate_cmd = nil
    for _, path in ipairs(venv_paths) do
        if vim.fn.filereadable(path) == 1 then
            activate_cmd = path
            break
        end
    end
    local run_cmd = ""
    if activate_cmd then
        -- Use bash to source and run Python file
        run_cmd = string.format('bash -c "source %s && python3 %s"', activate_cmd, filename)
    else
        -- No venv found, just run with system Python
        run_cmd = "python3 " .. filename .. " " .. extra_args
    end
    require("toggleterm.terminal").Terminal
        :new({
            cmd = run_cmd,
            direction = "float",
            close_on_exit = false,
        })
        :toggle()
end

local function run_rust(...)
    local Terminal = require("toggleterm.terminal").Terminal

    -- Get full path of the current file
    local current_file = vim.fn.expand "%:p"

    -- Search upwards for Cargo.toml
    local cargo_toml = vim.fn.findfile("Cargo.toml", vim.fn.fnamemodify(current_file, ":h") .. ";")
    if cargo_toml == "" then
        print "Cargo.toml not found."
        return
    end

    -- Get the directory of Cargo.toml
    local project_root = vim.fn.fnamemodify(cargo_toml, ":h")

    -- Save current file before running
    vim.cmd "write"

    -- Create and toggle the terminal with cargo run
    local cargo_term = Terminal:new {
        cmd = "cd " .. project_root .. " && cargo run",
        direction = "float",
        close_on_exit = false,
        hidden = true,
    }

    cargo_term:toggle()
end

local function run_cpp_cmake(additional_cmds, extra_args)
    local current_file = vim.fn.expand "%:p"
    local cmake_file = vim.fn.findfile("CMakeLists.txt", vim.fn.fnamemodify(current_file, ":h") .. ";")
    -- project root (directory containing CMakeLists.txt)
    local project_root = vim.fn.fnamemodify(cmake_file, ":h")

    -- save all buffers
    vim.cmd "wa"

    -- read file and search for a project(...) line (case-insensitive, handles quotes)
    local lines = vim.fn.readfile(cmake_file)
    local project_name = nil
    for _, line in ipairs(lines) do
        -- match project(Name ...), project("Name"), project('Name')
        local name = line:match "[Pp][Rr][Oo][Jj][Ee][Cc][Tt]%s*%(%s*[\"']?([^%s%)\"']+)"
        if name and #name > 0 then
            project_name = name
            break
        end
    end

    -- fallback to current file basename (no extension) if project(...) not found
    if not project_name or project_name == "" then project_name = vim.fn.fnamemodify(current_file, ":t:r") end

    -- build + run command using project root/build
    local commands = {
        "cd " .. vim.fn.shellescape(project_root),
        "cmake -B build -DCMAKE_BUILD_TYPE=Debug",
        "cmake --build build",
        "export ASAN_OPTIONS=symbolize=1:print_stacktrace=1:halt_on_error=1:abort_on_error=1",
        "./build/" .. vim.fn.shellescape(project_name) .. " " .. extra_args,
    }
    local cmd = table.concat(commands, " && ")

    require("toggleterm.terminal").Terminal
        :new({
            cmd = cmd,
            direction = "float",
            close_on_exit = false,
            hidden = true,
        })
        :toggle()
end

local function run_cpp(additional_cmds, extra_args)
    -- Build + run CMake project (searches upward for CMakeLists.txt)
    local current_file = vim.fn.expand "%:p"
    local cmake_file = vim.fn.findfile("CMakeLists.txt", vim.fn.fnamemodify(current_file, ":h") .. ";")

    if cmake_file ~= "" then
        run_cpp_cmake(additional_cmds)
        return
    end

    vim.cmd "w" -- Save the file just in case
    local output = vim.fn.expand "%:r"
    if additional_cmds ~= nil then
        output = additional_cmds .. " && " .. output .. " " .. extra_args
    end
    require("toggleterm.terminal").Terminal:new({ cmd = output, direction = "float", close_on_exit = false }):toggle()
end

local function run_c(additional_cmds, extra_args)
    vim.cmd "w" -- Save the file just in case
    -- local file_with_ext = vim.fn.expand "%:t"
    -- local file_name = file_with_ext:gsub("%.c$", "")
    -- local output = "./" .. file_name
    local output = vim.fn.expand "%:r"
    if additional_cmds ~= nil then
        output = additional_cmds .. " && " .. output .. " " .. extra_args
    end
    require("toggleterm.terminal").Terminal:new({ cmd = output, direction = "float", close_on_exit = false }):toggle()
end

local function run_cuda(...)
    vim.cmd "w" -- save file
    local file = vim.fn.expand "%"
    local file_escaped = vim.fn.shellescape(file)
    local filename = vim.fn.expand "%:t:r"
    local compile_cmd = "nvcc -o " .. filename .. " " .. file_escaped
    local run_cmd = "./" .. filename

    local terminal = require("toggleterm.terminal").Terminal:new {
        cmd = compile_cmd .. " && " .. run_cmd,
        direction = "float",
        close_on_exit = false,
        hidden = true,
    }
    terminal:toggle()
end

local function run_bash_sh(_, extra_args)
    vim.cmd "w" -- save file
    local cwd = vim.fn.getcwd()
    local venv_paths = {
        cwd .. "/venv/bin/activate",
        cwd .. "/.venv/bin/activate",
    }
    local activate_cmd = nil
    for _, path in ipairs(venv_paths) do
        if vim.fn.filereadable(path) == 1 then
            activate_cmd = path
            break
        end
    end
    local file = vim.fn.expand "%"
    local file_escaped = vim.fn.shellescape(file)
    local run_cmd = ""
    if activate_cmd then
        -- Use bash to source and run bash
        run_cmd = string.format('bash -c "source %s && sh %s %s"', activate_cmd, file_escaped, extra_args)
    else
        run_cmd = "sh " .. file_escaped .. " " .. extra_args
    end
    require("toggleterm.terminal").Terminal
        :new({
            cmd = run_cmd,
            direction = "float",
            close_on_exit = false,
        })
        :toggle()
end

local function run_asm(...)
    vim.cmd "w" -- save file
    local file = vim.fn.expand "%"
    local file_escaped = vim.fn.shellescape(file)
    local filename = vim.fn.expand "%:t:r"
    local compile_cmd = "as -o " .. filename .. ".o " .. file_escaped
    local link_cmd = "ld -o " .. filename .. " " .. filename .. ".o"
    local run_cmd = "./" .. filename

    local terminal = require("toggleterm.terminal").Terminal:new {
        cmd = compile_cmd .. " && " .. link_cmd .. " && " .. run_cmd,
        direction = "float",
        close_on_exit = false,
        hidden = true,
    }
    terminal:toggle()
end

local function actual_run(additional_cmds, extra_args)
    local filetype = vim.bo.filetype
    if filetype == "java" then
        run_java(additional_cmds, extra_args)
    elseif filetype == "python" then
        run_python(additional_cmds, extra_args)
    elseif filetype == "rust" then
        run_rust(additional_cmds, extra_args)
    elseif filetype == "cuda" then
        run_cuda(additional_cmds, extra_args)
    elseif filetype == "cpp" then
        run_cpp(additional_cmds, extra_args)
    elseif filetype == "c" then
        run_c(additional_cmds, extra_args)
    elseif filetype == "sh" or filetype == "bash" then
        run_bash_sh(additional_cmds, extra_args)
    elseif filetype == "asm" then
        run_asm(additional_cmds, extra_args)
    else
        print("No run command configured for filetype: " .. filetype)
    end
end

function run.run_file(additional_cmds)
    local args_files = vim.fn.glob("*.args", false, true)
    local extra_args = ""
    if #args_files > 0 then
        -- Find all .args file and use telescope to select one
        local opts = {}
        for _, file in ipairs(args_files) do
            table.insert(opts, file)
        end
        table.insert(opts, "Enter args manually")
        -- Add an option to enter args manually
        vim.ui.select(opts, { prompt = "Select args file:" }, function(choice)
            if choice then
                if choice == "Enter args manually" then
                    vim.ui.input({ prompt = "Additional args: " }, function(input)
                        if input then
                            actual_run(additional_cmds, input)
                        end
                    end)
                    return
                end
                extra_args = vim.fn.trim(vim.fn.join(vim.fn.readfile(choice), " "))
                actual_run(additional_cmds, extra_args)
            end
        end)
    else
        -- Ask for additional args
        vim.ui.input({ prompt = "Additional args: " }, function(input)
            if input then
                actual_run(additional_cmds, input)
            end
        end)
    end
end

return run
