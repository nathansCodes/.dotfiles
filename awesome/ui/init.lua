local beautiful = require("beautiful")
local gears = require("gears")
-- theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "ui/theme.lua")

-- bar
require("ui.bar")

-- client ui
require("ui.client")

-- notification beautification
require("ui.notification")
