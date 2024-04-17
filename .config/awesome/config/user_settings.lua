local awful = require("awful")
local gears = require("gears")
local gtable = gears.table
local gfs = gears.filesystem
local beautiful = require("beautiful")

local json = require("modules.json")
local helpers = require("helpers")

local settings = {}

settings.defaults = {
    program = {
        autostart = { },
        default_apps = {
            terminal          = { name    = "Alacritty",
                                  command = "alacritty",
                                  fallback_icon = "apps/terminal.svg" },
            music_player      = { name    = "Spotube",
                                  command = "spotube",
                                  fallback_icon = "" },
            text_editor       = { name    = "Neovim",
                                  command = "alacritty -e nvim",
                                  fallback_icon = "" },
            code_editor       = { name    = "Neovim",
                                  command = "alacritty -e nvim",
                                  fallback_icon = "" },
            browser           = { name    = "firefox",
                                  command = "flatpak run org.mozilla.firefox",
                                  fallback_icon = "apps/chromium.svg" },
            file_manager      = { name    = "Nautilus",
                                  command = "nautilus",
                                  fallback_icon = "places/folder.svg" },
            network_manager   = { name    = "Networks",
                                  command = "nm-connection-editor",
                                  fallback_icon = "" },
            bluetooth_manager = { name    = "Bluetooth Connections",
                                  command = "blueman-manager",
                                  fallback_icon = "" },
        }
    },
    theme = {
        theme = "catppuccin",
        variant = "mocha",
        icon_theme = "Papirus-Dark",
        compositor_enabled = true,
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
    device = {
        audio = "pipewire",
        network = {
            wifi = "wlo1",
            lan = "eno1",
        }
    },
    layouts = { "us" }
}

-- functions for handling default values

local function set_default_apps(apps, fallbacks)
    for key, fallback in pairs(fallbacks) do
        local app = apps[key]
        if type(app) == "string" then
            apps[key] = {
                name = app,
                command = app,
                fallback_icon = fallback.fallback_icon
            }
        elseif type(app) == "table" then
            if type(app.name) == "string" then
                if type(app.command) ~= "string" then
                    app.command = app.name
                end
            else
                apps[key] = fallback
            end
        else
            apps[key] = fallback
        end
        apps[key].get_icon = function(self)
            local icons = beautiful.icon_theme_path .. "/32x32/apps/"

            if type(self.icon) == "string" and gfs.file_readable(icons..self.icon) then
                return icons..self.icon
            end

            if gfs.file_readable(icons..self.name..".svg") then
                self.icon = icons..self.name..".svg"
            elseif gfs.file_readable(icons..helpers.str.switch_case_first_letter(self.name)..".svg") then
                self.icon = icons..helpers.str.switch_case_first_letter(self.name)..".svg"
            else
                self.icon = beautiful.icon_theme_path .. "/32x32/" .. app.fallback_icon
            end

            return self.icon
        end
    end
end

--- Apply defaults if value hasn't been set. I can't use gears.table.crush
--- because that overrides child tables instead of recursing into them
local function apply_defaults(table, defaults)
    for k, def in pairs(defaults) do
        if type(def) == "table" then
            if type(table[k]) ~= "table" then
                table[k] = def
            else
                if k == "default_apps" then
                    set_default_apps(table[k], def)
                else
                    apply_defaults(table[k], def)
                end
            end
        else
            if table[k] == nil then
                table[k] = def
            end
        end
    end
end

collectgarbage("collect")

local settings_path = gfs.get_configuration_dir() .. "settings.json"

local json_str = ""
local data

if gfs.file_readable(settings_path) then
    -- TODO: handle this better. The longer the settings.json, the longer the startup time
    json_str = io.popen("cat " .. settings_path, "r"):read("*all")

    data = json.decode(json_str)

    apply_defaults(data, settings.defaults)
    if not data.program.default_apps then
        data.program.default_apps = {}
        set_default_apps(data.program.default_apps, settings.defaults.program.default_apps)
    end
else
    data = settings.defaults
end

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
                    if not startup then
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

local function __newindex(_, k, v)
    data_proxy[k] = v
    update_json()
end

function settings.reload()
    json_str = io.popen("cat " .. settings_path, "r"):read("*all")
    data = gtable.crush(settings.defaults, json.decode(json_str), true)
    data_proxy = {}
    startup = true
    setmetatables(data, data_proxy)
    startup = false
    setmetatable(settings, { __index = data_proxy, __newindex = __newindex })
end

local mt = {}

mt.__index = data_proxy
mt.__newindex = __newindex

return setmetatable(settings, mt)
