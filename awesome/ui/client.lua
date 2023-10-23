local gears = require("gears")
local wibox = require("wibox")
local ruled = require("ruled")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- titlebar
require("ui.titlebar")

local client_shape = beautiful.base_shape

local client_shape_max = function(cr, w, h)
    gears.shape.partially_rounded_rect(cr, w, h, true, true, false, false, 20)
end

local client_shape_fullscreen = function(cr, w, h)
    gears.shape.rectangle(cr, w, h)
end


client.connect_signal("manage", function(c, startup)
    -- set rounded corners for all clients
    c.shape = client_shape
    -- move clients to focused screen when being created
    if not startup then awful.client.movetoscreen(c, mouse.screen) end
    -- raise and focus newly created client
    c:raise()
    c:activate()
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
        c.shape = client_shape_fullscreen
    else
        c.shape = client_shape
    end
end)
