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
    end
    if filetype == "java" then
        -- Create a build folder and put everything there
        if vim.fn.isdirectory("build") == 0 then
            vim.fn.mkdir("build")
        end
        vim.cmd "w" -- save file
        local cmd = "javac -d build $(find . -name '*.java')"
        return cmd
    end
    return nil
end

function run.compile_file()
    local cmd = run.compile_only()
    if cmd == nil then
        print("No compile command configured for filetype: " .. vim.bo.filetype)
        return
    end
    require("toggleterm.terminal").Terminal:new({ cmd = cmd, direction = "float", close_on_exit = false }):toggle()
end

local function run_gradle(additional_cmds, extra_args)
    vim.cmd "wa"
    local cmd = "gradle run --args='" .. extra_args .. "'"
    if additional_cmds ~= nil then
        cmd = additional_cmds .. " && " .. cmd
    end
    return cmd
end

local function run_java(additional_cmds, extra_args)
    -- Check if it's a gradle project (build.gradle file exists) (bubble up)
    -- Then run using gradle
    local current_file = vim.fn.expand "%:p"
    local gradle_file = vim.fn.findfile("build.gradle", vim.fn.fnamemodify(current_file, ":h") .. ";")
    if gradle_file ~= "" then
        return run_gradle(additional_cmds, extra_args)
    end

    vim.cmd "w" -- save file
    local file = vim.fn.expand "%:p"
    -- local file_escaped = vim.fn.shellescape(file)
    -- local classname = vim.fn.expand "%:t:r"
    -- vim.cmd("!javac " .. file_escaped)
    local cmd = "java -cp build " .. file
    if additional_cmds ~= nil then
        cmd = additional_cmds .. " && " .. cmd
    end
    cmd = cmd .. " " .. extra_args
    return cmd
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
    return run_cmd
end

local function run_rust(...)
    local Terminal = require("toggleterm.terminal").Terminal

    -- Get full path of the current file
    local current_file = vim.fn.expand "%:p"

    -- Search upwards for Cargo.toml
    local cargo_toml = vim.fn.findfile("Cargo.toml", vim.fn.fnamemodify(current_file, ":h") .. ";")
    if cargo_toml == "" then
        vim.notify("Cargo.toml not found.", vim.log.levels.ERROR)
        return ""
    end

    -- Get the directory of Cargo.toml
    local project_root = vim.fn.fnamemodify(cargo_toml, ":h")

    -- Save current file before running
    vim.cmd "w"

    -- Create and toggle the terminal with cargo run
    local cmd = "cd " .. project_root .. " && cargo run"
    return cmd
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
        "cmake -B build -D CMAKE_BUILD_TYPE=Debug",
        "cmake --build build",
        "export ASAN_OPTIONS=symbolize=1:print_stacktrace=1:halt_on_error=1:abort_on_error=1",
        "cd build",
        "./" .. vim.fn.shellescape(project_name) .. " " .. extra_args,
    }
    local cmd = table.concat(commands, " && ")

    return cmd
end

local function run_cpp(additional_cmds, extra_args)
    -- Build + run CMake project (searches upward for CMakeLists.txt)
    local current_file = vim.fn.expand "%:p"
    local cmake_file = vim.fn.findfile("CMakeLists.txt", vim.fn.fnamemodify(current_file, ":h") .. ";")

    if cmake_file ~= "" then
        return run_cpp_cmake(additional_cmds, extra_args)
    end

    vim.cmd "w" -- Save the file just in case
    local output = vim.fn.expand "%:r"
   if not string.match(output, "^[./]") and not string.match(output, "^/") then
        output = "./" .. output
    end

    if additional_cmds ~= nil then
        output = additional_cmds .. " && " .. output
    end
    output = output .. " " .. extra_args
    return output
end

local function run_c(additional_cmds, extra_args)
    vim.cmd "w" -- Save the file just in case
    -- local file_with_ext = vim.fn.expand "%:t"
    -- local file_name = file_with_ext:gsub("%.c$", "")
    -- local output = "./" .. file_name
    local output = vim.fn.expand "%:r"
    if not string.match(output, "^[./]") and not string.match(output, "^/") then
        output = "./" .. output
    end

    if additional_cmds ~= nil then
        output = additional_cmds .. " && " .. output
    end
    output = output .. " " .. extra_args
    return output
end

local function run_cuda(...)
    vim.cmd "w" -- save file
    local file = vim.fn.expand "%"
    local file_escaped = vim.fn.shellescape(file)
    local filename = vim.fn.expand "%:t:r"
    local compile_cmd = "nvcc -o " .. filename .. " " .. file_escaped
    local run_cmd = "./" .. filename


    local final_cmd = compile_cmd .. " && " .. run_cmd
    return final_cmd
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
    return run_cmd
end

local function run_asm(...)
    vim.cmd "w" -- save file
    local file = vim.fn.expand "%"
    local file_escaped = vim.fn.shellescape(file)
    local filename = vim.fn.expand "%:t:r"
    local compile_cmd = "as -o " .. filename .. ".o " .. file_escaped
    local link_cmd = "ld -o " .. filename .. " " .. filename .. ".o"
    local run_cmd = "./" .. filename

    local final_cmd = compile_cmd .. " && " .. link_cmd .. " && " .. run_cmd

    return final_cmd
end

-- Find project root (example using .git as marker)
local function find_project_root()
    local dir = vim.fn.getcwd()
    while dir ~= "/" do
        if vim.fn.isdirectory(dir .. "/.git") == 1 then
            return dir
        end
        dir = vim.fn.fnamemodify(dir, ":h") -- go up one level
    end
    return vim.fn.getcwd() -- fallback to cwd
end

-- Search from project root down to cwd for the given script name
-- Returns the directory containing the file, or nil if not found
local function find_script_dir(script_name)
    local project_root = find_project_root()
    local cwd = vim.fn.getcwd()

    local path = project_root
    local found_dir = nil

    -- Get relative path from project_root to cwd
    local rel_path = vim.fn.fnamemodify(cwd, ":." .. project_root)
    local parts = vim.split(rel_path, "/", { plain = true })

    -- Walk down from project_root toward cwd
    for i = 0, #parts do
        local candidate = path .. "/" .. script_name
        if vim.fn.filereadable(candidate) == 1 then
            found_dir = path
            break
        end
        if i < #parts then
            path = path .. "/" .. parts[i+1]
        end
    end

    return found_dir
end

local function actual_run(additional_cmds, extra_args)
    -- Check if run.sh exists in the current directory
    -- If it exists, use it to run the file

    local cmd = ""
    local script_name = "run.sh"
    local run_path = find_script_dir(script_name)
    if run_path then
        vim.cmd "w" -- save file
        cmd = "cd " .. run_path .. " && bash " .. script_name .. " " .. extra_args
        if additional_cmds ~= nil then
            cmd = additional_cmds .. " && " .. cmd
        end
    else
        local filetype = vim.bo.filetype
        if filetype == "java" then
            cmd = run_java(additional_cmds, extra_args)
        elseif filetype == "python" then
            cmd = run_python(additional_cmds, extra_args)
        elseif filetype == "rust" then
            cmd = run_rust(additional_cmds, extra_args)
        elseif filetype == "cuda" then
            cmd = run_cuda(additional_cmds, extra_args)
        elseif filetype == "cpp" then
            cmd = run_cpp(additional_cmds, extra_args)
        elseif filetype == "c" then
            cmd = run_c(additional_cmds, extra_args)
        elseif filetype == "sh" or filetype == "bash" then
            cmd = run_bash_sh(additional_cmds, extra_args)
        elseif filetype == "asm" then
            cmd = run_asm(additional_cmds, extra_args)
        else
            print("No run command configured for filetype: " .. filetype)
        end
    end

    local post_process_cmd = "sh -c '" .. cmd .. "'"
    -- local post_process_cmd = cmd
    vim.notify("Running: " .. post_process_cmd, vim.log.levels.INFO)
    require("toggleterm.terminal").Terminal
    :new({
        cmd = post_process_cmd,
        direction = "float",
        close_on_exit = false,
    })
    :toggle()
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
                        if input ~= nil then
                            extra_args = input
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
            if input ~= nil then
                extra_args = input
                actual_run(additional_cmds, extra_args)
            end
        end)
    end
end

return run
