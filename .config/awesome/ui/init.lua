local beautiful = require("beautiful")
local gears = require("gears")

-- theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "ui/theme/init.lua")

-- notification beautification
require("ui.components.notification")

-- titlebars
require("ui.components.titlebar")

-- screenshot handler
require("ui.components.screenshooter")

-- per-screen ui components
local bar = require("ui.components.bar")
local dock = require("ui.components.dock")
local lockscreen = require("ui.components.lockscreen")
local powermenu = require("ui.components.powermenu")
screen.connect_signal("request::desktop_decoration", function(s)
    bar(s)
    dock(s)
    lockscreen(s)
    powermenu(s)
end)

-- launcher
require("ui.components.launcher")
