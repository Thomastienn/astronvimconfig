local python_venv = "~/.virtualenvs/neovim/bin/activate"
local run = {}

local function run_cmd(cmd, toggleterm_opts)
    cmd = "bash -c 'time (" .. cmd .. ")' || true"
    vim.notify("Running: " .. cmd, vim.log.levels.INFO)

    local default_opts = {
        cmd = cmd,
        direction = "float",
        close_on_exit = false,
    }
    local opts = vim.tbl_extend("force", default_opts, toggleterm_opts or {})

    require("toggleterm.terminal").Terminal
    :new(opts)
    :toggle()
end

local function get_exec_path()
    local filepath = vim.fn.expand "%:p"
    local parent = vim.fn.fnamemodify(filepath, ":h")
    local filename = vim.fn.expand "%:t:r"
    local exe_path = parent .. "/build/" .. filename
    return exe_path
end

local function full_screen_opt()
    return {
        direction = "float",
        float_opts = {
            width = vim.o.columns,
            height = vim.o.lines,
            row = 0,
            col = 0,
        }
    }
end

local function compile_c_cpp(callback, filetype)
    vim.cmd "w" -- save current file

    local src = vim.fn.expand "%:p"                  -- absolute path of current file
    local root = vim.fn.getcwd()                     -- project root
    local rel_dir = vim.fn.fnamemodify(src, ":.:h") -- relative folder of source
    local basename = vim.fn.fnamemodify(src, ":t:r") -- filename without extension

    local out_dir = root .. "/build/" .. rel_dir
    vim.fn.mkdir(out_dir, "p")                      -- make dirs if needed

    local output = out_dir .. "/" .. basename
    local flags = filetype == "cpp" and
                "g++ -DLOCAL -std=c++23 -O2 -Wall -Wextra -Wshadow" or
                "gcc -std=c99"

    local cmd = string.format("%s %s -o %s", flags, src, output)
    callback(cmd)
end

local function compile_java(callback)
    vim.cmd "w"
    local file_dir = vim.fn.expand("%:p:h")              -- /home/thomas/solve/testjava
    local source_root = vim.fn.fnamemodify(file_dir, ":h")  -- /home/thomas/solve
    local package_folder = vim.fn.expand("%:p:h:t")         -- testjava

    local cmd = 'cd "' .. source_root .. '" && javac -d build $(find "' .. package_folder .. '" -name "*.java")'
    callback(cmd)
end

local function compile_dockerfile(callback)
    vim.cmd "w" -- save file
    local ok, image_name = pcall(vim.fn.input, { prompt = "Enter Docker image name: " })
    if not ok or image_name == nil or image_name == "" then
        vim.notify("Image name cannot be empty", vim.log.levels.ERROR)
        callback(nil)
        return
    end
    local ok2, extra_flags = pcall(vim.fn.input, { prompt = "Enter extra docker build flags (or leave empty): ", completion = "file" })
    if ok2 and extra_flags ~= nil and extra_flags ~= "" then
        image_name = image_name .. " " .. extra_flags
    end
    local cmd = "docker build -t " .. image_name .. " ."
    callback(cmd)
end

local function compile_asm(callback)
    vim.cmd "w"
    local file = vim.fn.expand "%"
    local filename = vim.fn.expand "%:t:r"

    local opts = { "arm", "arm-emu", "arm-emu-gcc", "arm-gcc", "m4", "m4-emu"}

    vim.ui.select(opts, { prompt = "Select architecture:" }, function(choice)
        if choice then
            if vim.fn.isdirectory("build") == 0 then
                vim.fn.mkdir("build")
            end
            local opts_params_to_run = { architecture = choice }

            if string.find(choice, "m4") then
                local m4_compile_cmd = "m4 " .. file .. " > build/" .. filename .. ".s"
                local gcc = "gcc"
                if choice == "m4-emu" then
                    gcc = "aarch64-linux-gnu-gcc"
                end
                local gcc_compile_cmd = gcc .. " -o build/" .. filename .. " build/" .. filename .. ".s"
                local compile_cmd = m4_compile_cmd .. " && " .. gcc_compile_cmd
                callback(compile_cmd, opts_params_to_run)
                return
            end

            local compile = "as"
            if string.find(choice, "emu") then
                compile = "aarch64-linux-gnu-as"
            end

            local link = "ld"
            if choice == "arm-emu" then
                link = "aarch64-linux-gnu-ld"
            elseif choice == "arm-gcc" then
                link = "gcc"
            elseif choice == "arm-emu-gcc" then
                link = "aarch64-linux-gnu-gcc"
            end

            local compile_cmd = compile .. " -o build/" .. filename .. ".o " .. file
            local link_cmd = link .. " -o build/" .. filename .. " build/" .. filename .. ".o"
            filename = "./build/" .. filename

            local full_compile = compile_cmd .. " && " .. link_cmd

            callback(full_compile, opts_params_to_run)
        end
    end)
end

-- Returns the cmd
function run.compile_only(callback)
    local filetype = vim.bo.filetype
    -- Everytime update new language, handle extra cmd in the run_file function

    -- Create a build folder and put everything there
    local build_folder = "build"
    if vim.fn.isdirectory(build_folder) == 0 then
        vim.fn.mkdir(build_folder)
    end
    if filetype == "cpp" or filetype == "c" then
        compile_c_cpp(callback, filetype)
        return
    end
    if filetype == "java" then
        compile_java(callback)
        return
    end
    if filetype == "dockerfile" then
        compile_dockerfile(callback)
        return
    end
    if filetype == "asm" then
        compile_asm(callback)
        return
    end
    callback(nil)
end

function run.compile_file(callback)
    local function callback(cmd)
        if cmd == nil then
            print("No compile command configured for filetype: " .. vim.bo.filetype)
            return
        end
        require("toggleterm.terminal").Terminal:new({ cmd = cmd, direction = "float", close_on_exit = false }):toggle()
    end
    run.compile_only(callback)
end

local function run_gradle(additional_cmds, extra_args)
    vim.cmd "wa"
    local cmd = "gradle run --args='" .. extra_args .. "'"
    if additional_cmds ~= nil then
        cmd = additional_cmds .. " && " .. cmd
    end
    run_cmd(cmd)
end

local function run_maven_javafx(additional_cmds, extra_args, project_root)
    vim.cmd "wa"
    local cmd = "cd " .. vim.fn.shellescape(project_root) .. " && mvn javafx:run"
    if extra_args ~= nil and extra_args ~= "" then
        -- Pass arguments via exec.args property
        cmd = cmd .. " -Dexec.args='" .. extra_args .. "'"
    end
    if additional_cmds ~= nil then
        cmd = additional_cmds .. " && " .. cmd
    end
    run_cmd(cmd)
end

local function is_javafx_maven_project(pom_path)
    -- Check if pom.xml contains javafx-maven-plugin
    local file = io.open(pom_path, "r")
    if not file then
        return false
    end
    local content = file:read("*a")
    file:close()
    return content:find("javafx%-maven%-plugin") ~= nil or content:find("org%.openjfx") ~= nil
end

local function run_java(additional_cmds, extra_args, callback)
    local current_file = vim.fn.expand "%:p"

    -- Check for Maven project with JavaFX (pom.xml)
    local pom_file = vim.fn.findfile("pom.xml", vim.fn.fnamemodify(current_file, ":h") .. ";")
    if pom_file ~= "" then
        local pom_abs = vim.fn.fnamemodify(pom_file, ":p")
        local pom_dir = vim.fn.fnamemodify(pom_abs, ":h")
        if is_javafx_maven_project(pom_abs) then
            run_maven_javafx(additional_cmds, extra_args, pom_dir)
            return
        end
        -- Regular Maven project (non-JavaFX) - use mvn exec:java or mvn compile exec:java
        vim.cmd "wa"
        local cmd = "cd " .. vim.fn.shellescape(pom_dir) .. " && mvn compile exec:java"
        if extra_args ~= nil and extra_args ~= "" then
            cmd = cmd .. " -Dexec.args='" .. extra_args .. "'"
        end
        if additional_cmds ~= nil then
            cmd = additional_cmds .. " && " .. cmd
        end
        run_cmd(cmd)
        return
    end

    -- Check for Gradle project
    local gradle_file = vim.fn.findfile("build.gradle", vim.fn.fnamemodify(current_file, ":h") .. ";")
    if gradle_file ~= "" then
        run_gradle(additional_cmds, extra_args)
        return
    end

    vim.cmd "w"
    local file_dir = vim.fn.expand("%:p:h")
    local source_root = vim.fn.fnamemodify(file_dir, ":h")
    local package_folder = vim.fn.expand("%:p:h:t")
    local package_and_class = package_folder .. "." .. vim.fn.expand("%:t:r")  -- testjava.a

    local compile_cmd = 'cd "' .. source_root .. '" && javac -d build $(find "' .. package_folder .. '" -name "*.java")'
    local run_c = 'java -cp build ' .. package_and_class

    local cmd = compile_cmd .. " && " .. run_c
    if additional_cmds ~= nil then
        cmd = additional_cmds .. " && " .. cmd
    end
    cmd = cmd .. " " .. extra_args
    run_cmd(cmd)
end

local function run_python(_, extra_args)
    vim.cmd "w" -- save file
    local filename = vim.fn.expand "%:p" -- full path
    local cwd = vim.fn.getcwd()
    local venv_paths = {
        cwd .. "/venv/bin/activate",
        cwd .. "/.venv/bin/activate",
        python_venv,
    }
    local activate_cmd = nil
    for _, path in ipairs(venv_paths) do
        if vim.fn.filereadable(path) == 1 then
            activate_cmd = path
            break
        end
    end
    local cmd = ""
    if activate_cmd then
        -- Use bash to source and run Python file
        cmd = string.format('bash -c "source %s && python3 %s %s"', activate_cmd, filename, extra_args)
    else
        -- No venv found, just run with system Python
        cmd = "python3 " .. filename .. " " .. extra_args
    end
    run_cmd(cmd)
end

local function run_rust(additional_cmds, extra_args)
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

    -- Just cargo run with extra args (run will auto build)
    local cmd = "cd " .. vim.fn.shellescape(project_root) .. " && cargo run -- " .. extra_args
    if additional_cmds ~= nil then
        cmd = additional_cmds .. " && " .. cmd
    end

    run_cmd(cmd)
end

local function run_cpp_cmake(additional_cmds, extra_args)
    local current_file = vim.fn.expand "%:p"
    local cmake_file = vim.fn.findfile("CMakeLists.txt", vim.fn.fnamemodify(current_file, ":h") .. ";")
    -- project root (directory containing CMakeLists.txt)
    local project_root = vim.fn.fnamemodify(cmake_file, ":h")

    -- save all buffers
    vim.cmd "wa"

    -- Make vim.select for multiple project names
    -- Get project name from CMakeLists.txt
    -- Pattern add_executable(<name> ...
    local project_names = {}
    for line in io.lines(cmake_file) do
        local name = line:match("add_executable%s*%(%s*([%w_]+)")
        if name then
            table.insert(project_names, name)
        end
    end

    if #project_names == 0 then
        vim.notify("No executable target found in CMakeLists.txt", vim.log.levels.ERROR)
        return
    end

    vim.ui.select(project_names, { prompt = "Select executable target:" }, function(choice)
        if choice then
            local project_name = choice
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
            run_cmd(cmd)
        end
    end)
end

local function run_cpp(additional_cmds, extra_args)
    -- Build + run CMake project (searches upward for CMakeLists.txt)
    local current_file = vim.fn.expand "%:p"
    local cmake_file = vim.fn.findfile("CMakeLists.txt", vim.fn.fnamemodify(current_file, ":h") .. ";")

    if cmake_file ~= "" then
        run_cpp_cmake(additional_cmds, extra_args)
        return
    end

    vim.cmd "w" -- Save the file just in case
    local output = vim.fn.expand "%:r"
    local parent = vim.fn.fnamemodify(output, ":h")
    local base = vim.fn.fnamemodify(output, ":t")
    output = parent .. "/build/" .. base

    if additional_cmds ~= nil then
        output = additional_cmds .. " && " .. output
    end
    output = output .. " " .. extra_args
    run_cmd(output)
end

local function run_c(additional_cmds, extra_args)
    vim.cmd "w" -- Save the file just in case
    -- local file_with_ext = vim.fn.expand "%:t"
    -- local file_name = file_with_ext:gsub("%.c$", "")
    -- local output = "./" .. file_name
    local output = vim.fn.expand "%:r"
    local parent = vim.fn.fnamemodify(output, ":h")
    local base = vim.fn.fnamemodify(output, ":t")
    output = parent .. "/build/" .. base

    if additional_cmds ~= nil then
        output = additional_cmds .. " && " .. output
    end
    output = output .. " " .. extra_args
    run_cmd(output)
end

local function run_cuda(...)
    vim.cmd "w" -- save file
    local file = vim.fn.expand "%"
    local file_escaped = vim.fn.shellescape(file)
    local filename = vim.fn.expand "%:t:r"
    local compile_cmd = "nvcc -o " .. filename .. " " .. file_escaped
    local runcmd = "./" .. filename


    local final_cmd = compile_cmd .. " && " .. runcmd
    run_cmd(final_cmd)
end

local function run_bash_sh(_, extra_args)
    vim.cmd "w" -- save file
    local cwd = vim.fn.getcwd()
    local venv_paths = {
        cwd .. "/venv/bin/activate",
        cwd .. "/.venv/bin/activate",
        python_venv,
    }
    local activate_cmd = nil
    for _, path in ipairs(venv_paths) do
        if vim.fn.filereadable(path) == 1 then
            activate_cmd = path
            break
        end
    end
    local file = vim.fn.expand "%:p"
    local file_escaped = vim.fn.shellescape(file)
    local cmd = ""
    if activate_cmd then
        -- Use bash to source and run bash
        cmd = string.format('bash -c "source %s && %s %s"', activate_cmd, file_escaped, extra_args)
    else
        cmd = file_escaped .. " " .. extra_args
    end
    run_cmd(cmd)
end

local function run_asm(additional_cmds, extra_args, opts_params_to_run)
    vim.cmd "w" -- save file
    local filename = get_exec_path()

    local run_cmd_map = {
        ["arm-emu"] = "qemu-aarch64 " .. filename,
        ["arm-emu-gcc"] = "qemu-aarch64 -L /usr/aarch64-linux-gnu " .. filename,
        ["m4-emu"] = "qemu-aarch64 -L /usr/aarch64-linux-gnu " .. filename,
    }

    local architecture = opts_params_to_run and opts_params_to_run.architecture or nil

    if architecture ~= nil then
        local cmd = run_cmd_map[architecture] or filename
        if additional_cmds ~= nil then
            cmd = additional_cmds .. " && " .. cmd
        end
        if extra_args ~= nil and extra_args ~= "" then
            cmd = cmd .. " " .. extra_args
        end
        run_cmd(cmd)
        return
    end

    local opts = { "arm", "arm-emu", "arm-emu-gcc", "arm-gcc", "m4", "m4-emu" }
    vim.ui.select(opts, { prompt = "Select architecture:" }, function(choice)
        if choice then
            local cmd = run_cmd_map[choice] or filename
            if additional_cmds ~= nil then
                cmd = additional_cmds .. " && " .. cmd
            end
            if extra_args ~= nil and extra_args ~= "" then
                cmd = cmd .. " " .. extra_args
            end
            run_cmd(cmd)
        end
    end)
end

local function run_go(additional_cmds, extra_args)
    vim.cmd "w" -- save file
    local file = vim.fn.expand "%:p"
    local file_escaped = vim.fn.shellescape(file)
    local cmd = "go run " .. file_escaped .. " " .. extra_args
    if additional_cmds ~= nil then
        cmd = additional_cmds .. " && " .. cmd
    end
    run_cmd(cmd)
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

local function run_executable(additional_cmds, extra_args)
    vim.cmd "w" -- save file
    local output = vim.fn.expand "%p"
    if not string.match(output, "^[./]") and not string.match(output, "^/") then
        output = "./" .. output
    end

    if additional_cmds ~= nil then
        output = additional_cmds .. " && " .. output
    end
    output = output .. " " .. extra_args
    run_cmd(output)
end


local function actual_run(additional_cmds, extra_args, opts_params_to_run)
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
        run_cmd(cmd)
    else
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
            run_asm(additional_cmds, extra_args, opts_params_to_run)
        elseif filetype == "go" then
            run_go(additional_cmds, extra_args)
        else
            run_executable(additional_cmds, extra_args)
        end
    end

end

local function debug_asm(extra_cmd)
    local cmd = extra_cmd or ""
    if cmd ~= "" then
        cmd = cmd .. " && "
    end
    local exe_path = get_exec_path()

    cmd = cmd .. "gdb " .. exe_path
    cmd = cmd .. ' -ex "break main" -ex "run" -ex "layout asm" -ex "layout regs" -ex "set pagination off"'

    run_cmd(cmd, full_screen_opt())
end

function run.debug_file()
    local filetype = vim.bo.filetype

    if filetype == "asm" then
        compile_asm(debug_asm)
    end
end

function run.run_file(additional_cmds, opts_params_to_run)
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
                    -- Use vim.fn.input for tab-completion on file paths
                    local ok, input = pcall(vim.fn.input, { prompt = "Additional args: ", completion = "file" })
                    if ok and input ~= "" then
                        actual_run(additional_cmds, input, opts_params_to_run)
                    end
                    return
                end
                extra_args = vim.fn.trim(vim.fn.join(vim.fn.readfile(choice), " "))
                actual_run(additional_cmds, extra_args, opts_params_to_run)
            end
        end)
    else
        -- Ask for additional args (with file path tab-completion)
        local ok, input = pcall(vim.fn.input, { prompt = "Additional args: ", completion = "file" })
        if ok and input ~= nil then
            extra_args = input
            actual_run(additional_cmds, extra_args, opts_params_to_run)
        end
    end
end

return run
