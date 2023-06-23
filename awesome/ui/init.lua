local beautiful = require("beautiful")
local gears = require("gears")
-- theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "ui/theme.lua")

-- bar
require("ui.bar")

