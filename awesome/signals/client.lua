local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local helpers = require("helpers")
local capi = { client = client, mouse = mouse }

local client_shape = helpers.ui.rrect(14)

capi.client.connect_signal("manage", function(c, startup)
    -- set rounded corners for all clients
    c.shape = client_shape

    -- move clients to focused screen when being created
    if not startup then awful.client.movetoscreen(c, capi.mouse.screen) end

    -- raise and focus newly created client
    c:raise()
    c:activate()

    --automatically focus a client when switching tags
    c:grant("autoactivate", "history")
end)

capi.client.connect_signal("property::maximized", function(c)
    if c.maximized == true then
        c.shape = gears.shape.rectangle
    else
        c.shape = client_shape
    end
end)

capi.client.connect_signal("property::fullscreen", function(c)
    if c.fullscreen == true then
        c.shape = gears.shape.rectangle
    else
        c.shape = client_shape
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
capi.client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
end)


