local export = {}

local function typst(input, output, format)
    local cmd = { "typst", "compile", input, output }
    if format == "html" then
        vim.list_extend(cmd, { "--features", "html" })
    end
    return cmd
end

local function pandoc(input, output, reader)
    return { "pandoc", "--from", reader, input, "--pdf-engine=typst", "-o", output }
end

local function latex(input)
    return { "latexmk", "-pdf", "-interaction=nonstopmode", "-halt-on-error", input }
end

-- All supported Neovim filetypes and their export formats live here.
-- Add a row with formats and a command(input, output, format) returning argv.
export.registry = {
    typst = { formats = { "pdf", "png", "svg", "html" }, command = typst },
    markdown = { formats = { "pdf" }, command = function(i, o) return pandoc(i, o, "markdown") end },
    text = { formats = { "pdf" }, command = function(i, o) return pandoc(i, o, "markdown") end },
    html = { formats = { "pdf" }, command = function(i, o) return pandoc(i, o, "html") end },
    rst = { formats = { "pdf" }, command = function(i, o) return pandoc(i, o, "rst") end },
    org = { formats = { "pdf" }, command = function(i, o) return pandoc(i, o, "org") end },
    tex = { formats = { "pdf" }, command = latex },
    latex = { formats = { "pdf" }, command = latex },
}

function export.formats(buf)
    local converter = export.registry[vim.bo[buf or 0].filetype]
    return converter and converter.formats or {}
end

function export.export_file(format, buf)
    buf = buf or vim.api.nvim_get_current_buf()
    format = (format and format ~= "") and format or "pdf"
    local converter = export.registry[vim.bo[buf].filetype]
    if not converter then
        vim.notify("No export converter for filetype: " .. vim.bo[buf].filetype, vim.log.levels.WARN)
        return
    end
    if not vim.tbl_contains(converter.formats, format) then
        vim.notify("Unsupported export format: " .. format, vim.log.levels.ERROR)
        return
    end
    local input = vim.api.nvim_buf_get_name(buf)
    if input == "" or vim.bo[buf].buftype ~= "" then
        vim.notify("Save the buffer to a file before exporting", vim.log.levels.ERROR)
        return
    end
    local ok, err = pcall(vim.api.nvim_buf_call, buf, function() vim.cmd "update" end)
    if not ok then
        vim.notify(tostring(err), vim.log.levels.ERROR)
        return
    end
    local suffix = (format == "png" or format == "svg") and "-{p}" or ""
    local output = vim.fn.fnamemodify(input, ":r") .. suffix .. "." .. format
    if output == input then
        vim.notify("Export would overwrite the source file", vim.log.levels.ERROR)
        return
    end
    local cmd = converter.command(input, output, format)
    if vim.fn.executable(cmd[1]) ~= 1 then
        vim.notify("Missing export command: " .. cmd[1], vim.log.levels.ERROR)
        return
    end
    vim.notify("Exporting to " .. output)
    local started, job = pcall(vim.system, cmd, { cwd = vim.fn.fnamemodify(input, ":h"), text = true }, function(result)
        vim.schedule(function()
            if result.code == 0 then
                vim.notify("Exported to " .. output)
            else
                local details = result.stderr ~= "" and result.stderr or result.stdout
                vim.notify("Export failed: " .. (details or ""), vim.log.levels.ERROR)
            end
        end)
    end)
    if not started then
        vim.notify("Could not start export: " .. tostring(job), vim.log.levels.ERROR)
    end
end

function export.export_picker()
    local buf = vim.api.nvim_get_current_buf()
    local formats = export.formats(buf)
    if #formats == 0 then
        vim.notify("No export converter for filetype: " .. vim.bo[buf].filetype, vim.log.levels.WARN)
        return
    end
    vim.ui.select(formats, { prompt = "Export format:" }, function(format)
        if format and vim.api.nvim_buf_is_valid(buf) then
            export.export_file(format, buf)
        end
    end)
end

return export
