-- Debugger
local dap = require("dap")
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = "/home/thomastien/my_bin/codelldb/extension/adapter/codelldb", -- change to your adapter path
    args = {"--port", "${port}"},
  }
}
dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
        local handle = io.popen("find build -maxdepth 1 -type f -executable | head -n 1")
        if not handle then
            print("Error: Unable to find executable in build directory")
            return
        end
        local result = handle:read("*a")
        handle:close()
        print("Debugging: " .. vim.trim(result))
        return vim.trim(result)
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {}, -- program arguments
  },
}

local function compile_current_asm()
  local src = vim.fn.expand("%:p")
  if src == "" then
    print("No file to compile (empty buffer?)")
    return nil
  end

  local out = vim.fn.expand("%:p:r")  -- same name without extension
  local compile_cmds = {
    -- try gcc/clang directly (works for AT&T/GAS-style .s or .asm with GCC-compatible syntax)
    string.format("gcc -g %s -o %s 2>&1", vim.fn.shellescape(src), vim.fn.shellescape(out)),
    -- fallback: assume NASM syntax: assemble then link via gcc to keep -g
    string.format("nasm -f elf64 %s -o %s.o 2>&1 && gcc -g %s.o -o %s 2>&1", vim.fn.shellescape(src), vim.fn.shellescape(out), vim.fn.shellescape(out), vim.fn.shellescape(out))
  }

  for _, cmd in ipairs(compile_cmds) do
    print("Running: " .. cmd)
    local result = vim.fn.system(cmd)
    local code = vim.v.shell_error
    if code == 0 then
      -- success
      return out
    else
      -- show compiler/linker output and continue to next fallback
      print("Compile attempt failed:\n" .. result)
    end
  end

  print("All compile attempts failed. Fix errors and try again.")
  return nil
end

-- configuration that compiles current ASM buffer and launches it
local asm_launch_compile = {
  name = "ASM: Compile current buffer & Launch",
  type = "codelldb",
  request = "launch",
  program = function()
    local exe = compile_current_asm()
    if not exe or exe == "" then
      -- return nil so dap won't start; user sees printed errors
      return nil
    end
    -- make sure absolute path
    return vim.fn.expand(exe)
  end,
  cwd = "${workspaceFolder}",
  stopOnEntry = false,
  args = {},
}

-- configuration that finds first executable in build/ (same pattern as your C++ config)
local asm_launch_build = {
  name = "ASM: Launch first executable in build/",
  type = "codelldb",
  request = "launch",
  program = function()
    local handle = io.popen("find build -maxdepth 1 -type f -executable | head -n 1")
    if not handle then
      print("Error: Unable to find executable in build directory")
      return
    end
    local result = handle:read("*a")
    handle:close()
    result = vim.trim(result)
    if result == "" then
      print("No executable found in build/. Build one or use the compile config.")
      return nil
    end
    print("Debugging: " .. result)
    return result
  end,
  cwd = "${workspaceFolder}",
  stopOnEntry = false,
  args = {},
}

-- optional: attach to a running PID (useful for stepping into short-lived processes)
local asm_attach = {
  name = "ASM: Attach to PID",
  type = "codelldb",
  request = "attach",
  pid = require('dap.utils').pick_process, -- interactive picker
  stopOnEntry = false,
}

-- register for common assembly filetypes
dap.configurations.asm = { asm_launch_compile, asm_launch_build, asm_attach }
dap.configurations.asmx86 = { asm_launch_compile, asm_launch_build, asm_attach } -- if you use asmx86
dap.configurations.nasm = { asm_launch_compile, asm_launch_build, asm_attach }  -- if filetype is 'nasm'
