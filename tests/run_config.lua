-- Run: nvim --headless -u NONE -l tests/run_config.lua
local repo = vim.fn.getcwd()
package.path = repo .. "/lua/?.lua;" .. package.path
local temp = vim.fn.tempname()
vim.fn.mkdir(temp, "p")
vim.cmd.cd(temp)
local run = require "run_file"
local selections, choice, compiler, errors = 0, "c89", "cc", 0
vim.ui.select = function(_, opts, callback)
    selections = selections + 1
    if opts.prompt:find("compiler", 1, true) then callback(compiler) else callback(choice) end
end
vim.notify = function(_, level)
    if level == vim.log.levels.ERROR then errors = errors + 1 end
end

local function source(name, lines, filetype)
    vim.fn.writefile(lines, name)
    vim.cmd.edit(name)
    vim.bo.filetype = filetype or "c"
end

local function compile()
    local command
    run.compile_only(function(cmd) command = cmd end)
    return command
end

local function build(command)
    local output = vim.fn.system(command)
    assert(vim.v.shell_error == 0, output)
end

local function save(config)
    vim.fn.writefile({ vim.json.encode(config) }, ".run.json")
end

local function read(path)
    return vim.json.decode(table.concat(vim.fn.readfile(path or ".run.json"), "\n"))
end

local ok, err = pcall(function()
    source("old.c", { "int main(void) { return 0; }" })
    local command = compile()
    assert(command:find("cc -std=c89", 1, true))
    assert(read().c.standard == "c89" and read().c.compiler == "cc")
    build(command)

    -- A fresh module and another file still reuse the on-disk choice.
    package.loaded.run_file = nil
    run = require "run_file"
    source("other.c", { "int main(void) { return 0; }" })
    assert(compile():find("cc -std=c89", 1, true))
    assert(selections == 2)

    save({ c = { standard = "c11" } })
    source("modern.c", { "_Static_assert(_Generic(1, int: 1, default: 0), \"C11 required\");", "int main(void) { return 0; }" })
    build(compile())
    assert(read().c.compiler == "cc" and read().c.standard == "c11")
    assert(selections == 3) -- Only the missing compiler was requested.
    save({ c = { compiler = "gcc", standard = "c2x" } })
    assert(compile():find("gcc -std=c2x", 1, true))
    build(compile())
    assert(selections == 3)

    save({ c = { standard = "c99; touch injected" } })
    assert(compile() == nil and errors == 1)
    for _, invalid in ipairs({ "{", "[]", "null", '{"c":false}', '{"c":[]}', '{"c":{"standard":null}}', '{"c":{"compiler":"cc; touch injected"}}', '{"c":{"compiler":false}}' }) do
        vim.fn.writefile({ invalid }, ".run.json")
        local previous_errors = errors
        assert(compile() == nil and errors == previous_errors + 1)
        assert(vim.fn.readfile(".run.json")[1] == invalid)
    end
    vim.fn.delete(".run.json")
    compiler = nil
    assert(compile() == nil)
    assert(vim.fn.filereadable(".run.json") == 0)
    compiler = "cc"
    choice = nil
    assert(compile() == nil)
    assert(vim.fn.filereadable(".run.json") == 0)

    -- Add a missing standard without losing other languages or future options.
    save({ python = { interpreter = "python3" }, c = { flags = { "-Wall" } } })
    choice = "c11"
    build(compile())
    local config = read()
    assert(config.c.standard == "c11" and config.c.flags[1] == "-Wall")
    assert(config.python.interpreter == "python3")
    vim.fn.delete(".run.json")

    -- Selecting in a different source folder saves beside that source.
    vim.fn.mkdir("sub", "p")
    source("sub/next.c", { "int main(void) { return 0; }" })
    choice = "c17"
    build(compile())
    assert(read("sub/.run.json").c.standard == "c17")
    assert(vim.fn.filereadable(".run.json") == 0)

    local previous = selections
    source("unchanged.cpp", { "int main() { return 0; }" }, "cpp")
    assert(compile():find("g++ -DLOCAL -std=c++23", 1, true))
    source("cmake.c", { "int main(void) { return 0; }" })
    vim.fn.writefile({}, "CMakeLists.txt")
    assert(compile() == nil and selections == previous)

    -- Another language uses the same resolver with text and boolean settings.
    save({ c = { compiler = "cc", standard = "c11" }, python = { extra = { "kept" } } })
    local fields = {
        {
            name = "interpreter",
            validate = function(value)
                return type(value) == "string" and value ~= "", "expected a nonempty string"
            end,
        },
        { name = "optimize", choices = { false, true } },
    }
    local prompts, resolved = 0, nil
    vim.ui.input = function(_, callback)
        prompts = prompts + 1
        vim.schedule(function() callback("python3") end)
    end
    vim.ui.select = function(_, _, callback)
        prompts = prompts + 1
        vim.schedule(function() callback(false) end)
    end
    local src = temp .. "/script.py"
    require("run_config").resolve(src, "python", fields, function(values) resolved = values end)
    assert(resolved == nil)
    assert(vim.wait(1000, function() return resolved ~= nil end))
    assert(resolved.interpreter == "python3" and resolved.optimize == false)
    config = read()
    assert(config.c.compiler == "cc" and config.c.standard == "c11")
    assert(config.python.extra[1] == "kept" and config.python.optimize == false)
    assert(prompts == 2)

    package.loaded.run_config = nil
    resolved = nil
    require("run_config").resolve(src, "python", fields, function(values) resolved = values end)
    assert(resolved.optimize == false and prompts == 2)

    -- Custom validation rejects new input without overwriting existing data.
    config.python.interpreter = nil
    save(config)
    local before = vim.fn.readfile(".run.json")[1]
    vim.ui.input = function(_, callback) callback("") end
    resolved = nil
    local previous_errors = errors
    require("run_config").resolve(src, "python", fields, function(values) resolved = values end)
    assert(resolved == nil and errors == previous_errors + 1)
    assert(vim.fn.readfile(".run.json")[1] == before)
end)
vim.cmd.cd(repo)
vim.fn.delete(temp, "rf")
assert(ok, err)
print("Reusable config checks and real cc/gcc builds passed")
