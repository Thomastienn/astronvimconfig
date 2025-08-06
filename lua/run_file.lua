local run = {}

local function run_java()
  vim.cmd "w" -- save file
  local file = vim.fn.expand "%"
  local file_escaped = vim.fn.shellescape(file)
  local classname = vim.fn.expand "%:t:r"
  local javafx_lib = vim.fn.expand "~/javafx/javafx-sdk-21.0.7/lib"
  local is_javafx = vim.fn.search "javafx\\.application\\.Application" ~= 0

  if is_javafx then
    -- compile into package dirs under project root
    local compile_cmd = table.concat({
      "javac",
      "-d",
      ".",
      "--module-path",
      '"' .. javafx_lib .. '"',
      "--add-modules",
      "javafx.controls,javafx.fxml",
      file_escaped,
    }, " ")

    -- figure out the FQCN from src/main/java/rw/app/…/Application.java
    local proj = vim.fn.getcwd()
    local src_root = proj .. "/src/main/java/"
    local fullpath = vim.fn.expand "%:p"
    local rel = fullpath:match(src_root .. "(.*)%.java$")
    local fqcn = rel and rel:gsub("/", ".") or classname

    -- run with -cp . and fully‑qualified name
    local run_cmd = table.concat({
      "java",
      "-cp",
      ".",
      "--module-path",
      '"' .. javafx_lib .. '"',
      "--add-modules",
      "javafx.controls,javafx.fxml",
      fqcn,
    }, " ")

    vim.cmd("!" .. compile_cmd)
    vim.cmd("!" .. run_cmd)
  else
    vim.cmd("!javac " .. file_escaped)
    vim.cmd("!java " .. classname)
  end
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
  else
    print("No run command configured for filetype: " .. filetype)
  end
end

return run
