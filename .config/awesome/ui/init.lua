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

screen.connect_signal("request::desktop_decoration", function(s)

    -- bar
    require("ui.components.bar")(s)

    -- dock
    require("ui.components.dock")(s)

end)

-- launcher
require("gears").protected_call(function()
require("ui.components.launcher")
end, function(e) require("naughty").notification { text = e, urgency = "critical" } end)


