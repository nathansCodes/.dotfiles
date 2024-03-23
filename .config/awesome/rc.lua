-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local naughty = require("naughty")
require("awful.hotkeys_popup.keys")

-- Error handling
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)

local gfs = require("gears").filesystem

-- make liblua_pan and libfzy accessible
package.cpath = package.cpath .. ";" .. gfs.get_configuration_dir() .. "modules/?.so"

-- load user settings on startup
require("config.user_settings")
require("ui")
require("signals")
require("config")
