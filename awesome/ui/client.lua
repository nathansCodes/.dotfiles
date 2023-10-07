local gears = require("gears")
local beautiful = require("beautiful")

local client_shape = beautiful.base_shape

local client_shape_max = function(cr, w, h)
    gears.shape.rectangle(cr, w, h)
end

-- set rounded corners for all clients
client.connect_signal("manage", function(c)
    c.shape = client_shape
end)

client.connect_signal("property::maximized", function(c)
    if c.maximized == true then
        c.shape = client_shape_max
    else
        c.shape = client_shape
    end
end)

client.connect_signal("property::fullscreen", function(c)
    if c.fullscreen == true then
        c.shape = client_shape_max
    else
        c.shape = client_shape
    end
end)

client.connect_signal("focus", function(c)
    c:raise()
end)
