local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local gtable = gears.table
local gfs = gears.filesystem

local json = require("modules.json")

local settings = {}

settings.defaults = {
    program = {
        autostart = { }
    },
    theme = {
        theme = "catppuccin",
        variant = "mocha",
        icon_theme = "Papirus-Dark",
        xresources_enabled = false,
        gtk = { enabled = false },
        nvim = { enabled = false },
        alacritty = { enabled = false },
        discord = {
            enabled = false,
            install = "flatpak",
            client_mod = "Vencord"
        },
        firefox = {
            enabled = false,
            profile = "",
            install = "native"
        }
    },
    locale = {
        langs = {
            "us"
        }
    }
}

local settings_path = gfs.get_configuration_dir() .. "settings.json"

-- TODO: handle this better. The longer the user_settings.json, the longer the startup time
local json_str = io.popen("cat " .. settings_path, "r"):read("*all")

local data = gtable.crush(settings.defaults, json.decode(json_str), true)

local data_proxy = {}

local function update_json()
    json_str = json.encode(data)
    awful.spawn.with_shell("echo -n '"..json_str.."' > "..settings_path)
end

function settings.get_json()
    return json.encode(data)
end

local startup = true
local function setmetatables(t, proxy)
    for k, v in pairs(t) do
        if type(v) == "table" then
            rawset(proxy, k, {})
            setmetatable(proxy[k], {
                __index = function(table, key)
                    if rawget(table, key) ~= nil then
                        return table[key]
                    else
                        return v[key]
                    end
                end,
                __newindex = function(_, key, val)
                    rawset(v, key, val)
                    if startup == false then
                        update_json()
                    end
                end
            })
            setmetatables(v, proxy[k])
        end
    end
end

setmetatables(data, data_proxy)
startup = false

local mt = {}

mt.__index = data_proxy
function mt.__newindex(_, k, v)
    data_proxy[k] = v
    update_json()
end

return setmetatable(settings, mt)
