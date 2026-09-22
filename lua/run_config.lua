local M = {}

local function load(path)
    if not vim.uv.fs_stat(path) then return vim.empty_dict() end
    local ok, config = pcall(function()
        return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
    end)
    if not ok or type(config) ~= "table" or vim.islist(config) then
        vim.notify("Invalid or unreadable " .. path .. ": expected a JSON object", vim.log.levels.ERROR)
        return
    end
    return config
end

local function save(path, config)
    local ok, result = pcall(function()
        return vim.fn.writefile({ vim.json.encode(config) }, path)
    end)
    if not ok or result ~= 0 then
        vim.notify("Could not save " .. path, vim.log.levels.ERROR)
        return false
    end
    return true
end

local function validate(path, section, fields, values)
    for _, field in ipairs(fields) do
        local value = values[field.name]
        if value ~= nil then
            local valid, reason = true, nil
            if field.choices and not vim.tbl_contains(field.choices, value) then
                valid, reason = false, "not a supported choice"
            elseif field.validate then
                valid, reason = field.validate(value)
            end
            if not valid then
                vim.notify("Invalid " .. path .. ": " .. section .. "." .. field.name .. ": " .. (reason or "invalid value"), vim.log.levels.ERROR)
                return false
            end
        end
    end
    return true
end

local function pick_missing(section, fields, values, callback)
    local changed = false
    local function next_field(index)
        local field = fields[index]
        if not field then
            callback(changed)
            return
        end
        if values[field.name] ~= nil then
            next_field(index + 1)
            return
        end
        local function selected(value)
            if value == nil then return end
            values[field.name] = value
            changed = true
            next_field(index + 1)
        end
        local opts = { prompt = section .. "." .. field.name .. " (saved in .run.json): " }
        if field.choices then
            opts.format_item = field.format_item
            vim.ui.select(field.choices, opts, selected)
        else
            vim.ui.input(opts, selected)
        end
    end
    next_field(1)
end

function M.resolve(src, section, fields, callback)
    local path = vim.fn.fnamemodify(src, ":h") .. "/.run.json"
    local config = load(path)
    if not config then return end
    local values = config[section]
    if values == nil then values = vim.empty_dict() end
    if type(values) ~= "table" or vim.islist(values) then
        vim.notify("Invalid " .. path .. ": " .. section .. " must be a JSON object", vim.log.levels.ERROR)
        return
    end
    if not validate(path, section, fields, values) then return end
    pick_missing(section, fields, values, function(changed)
        if changed then
            if not validate(path, section, fields, values) then return end
            config[section] = values
            if not save(path, config) then return end
        end
        callback(values)
    end)
end

return M
