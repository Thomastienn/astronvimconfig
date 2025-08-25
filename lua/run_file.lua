local run = {}

local function run_java()
    vim.cmd "w" -- save file
    local file = vim.fn.expand "%"
    local file_escaped = vim.fn.shellescape(file)
    local classname = vim.fn.expand "%:t:r"
    vim.cmd("!javac " .. file_escaped)
    vim.cmd("!java " .. classname)
end

local function run_python()
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
        run_cmd = "python3 " .. filename
    end
    require("toggleterm.terminal").Terminal
        :new({
            cmd = run_cmd,
            direction = "float",
            close_on_exit = false,
        })
        :toggle()
end

local function run_rust()
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

local function run_cpp()
    vim.cmd "w" -- Save the file just in case
    local file_with_ext = vim.fn.expand "%:t"
    local file_name = file_with_ext:gsub(".cpp", "")
    local output = "./" .. file_name
    require("toggleterm.terminal").Terminal:new({ cmd = output, direction = "float", close_on_exit = false }):toggle()
end

local function run_cuda()
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

local function run_bash_sh()
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
        run_cmd = string.format('bash -c "source %s && sh %s"', activate_cmd, file_escaped)
    else
        run_cmd = "sh " .. file_escaped
    end
    require("toggleterm.terminal").Terminal
        :new({
            cmd = run_cmd,
            direction = "float",
            close_on_exit = false,
        })
        :toggle()
end

function run.run_file()
    local filetype = vim.bo.filetype
    if filetype == "java" then
        run_java()
    elseif filetype == "python" then
        run_python()
    elseif filetype == "rust" then
        run_rust()
    elseif filetype == "cuda" then
        run_cuda()
    elseif filetype == "cpp" then
        run_cpp()
    elseif filetype == "sh" or filetype == "bash" then
        run_bash_sh()
    else
        print("No run command configured for filetype: " .. filetype)
    end
end

return run
