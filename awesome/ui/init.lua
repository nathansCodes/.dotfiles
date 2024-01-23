local beautiful = require("beautiful")
local gears = require("gears")

-- theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "ui/theme/init.lua")

-- notification beautification
require("ui.components.notification")

-- titlebars
require("ui.components.titlebar")

-- bar
require("ui.components.bar")

-- screenshot handler
require("ui.components.screenshooter")

