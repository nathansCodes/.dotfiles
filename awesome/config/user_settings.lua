local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local gtable = gears.table
local gfs = gears.filesystem

local json = require("modules.json")

local settings = {}

settings.defaults = {
    theme = {
        theme = "Catppuccin",
        variant = "mocha",
        firefox_install = "native",
    },
    locale = {
        keyboard_layouts = { "us" },
    },
}

local settings_path = gfs.get_configuration_dir() .. "settings.json"

-- TODO: handle this better. The longer the user_settings.json, the longer the startup time
local json_str = io.popen("cat " .. settings_path, "r"):read("*all")

local settings_data = gtable.crush(settings.defaults, json.decode(json_str), true)

---Returns the requested value from the settings
---@param key string The path to the requested value. Use '.' as a separator for nested values
---@return any value
function settings.get(key)
    if type(key) ~= "string" then
        error("expected argument of type string|table, got " .. type(key))
    end

    local path = {}

    for k in key:gmatch("[^.]+") do
        table.insert(path, k)
    end

    local v = settings_data

    for _, field in pairs(path) do
        if type(v[field]) ~= "table" then return v[field] end
        if v[field] == nil then
            v = settings.defaults
            for _, field in pairs(path) do
                if type(v[field]) ~= "table" then return v[field] end
                v = v[field]
            end
            return v
        end
        v = v[field]
    end

    return v
end

local function concat_table(t)
    local ret = "{"
    for k, v in pairs(t) do
        if type(v) == "table" then v = concat_table(v) end
        if type(k) ~= "number" then
            ret = ret .. k .. "=" .. v .. ","
        else
            ret = ret .. v .. ","
        end
    end
    ret = ret .. "}"
    return ret
end

--- @param key string The path to the value to set. Use '.' as a separator for nested values
--- @param value any the value to set
function settings.set(key, value)
    -- creates a snippet of lua code that sets the value
    -- and runs said snippet. I didn't find another way to deal with nested values
    local eval = "settings_data"

    for field in key:gmatch("[^.]+") do
        eval = eval .. "['" .. field .. "']"
    end

    -- surround with quotes if value is a string
    local value_str = type(value) == "string" and '"'..value..'"' or tostring(value)

    -- handle case of value being a table
    if type(value) == "table" then
        value_str = concat_table(value)
    end

    -- returns a function with a paramater so that it can access settings_data
    eval = "return function(settings_data)" .. eval .. "=" .. value_str .. " end"
    -- load, call and run
    load(eval)()(settings_data)

    -- write to settings.json
    json_str = json.encode(settings_data)
    awful.spawn.with_shell("echo -n '"..json_str.."' > "..settings_path)
end

return settings
