local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gfs = gears.filesystem
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local bling = require("bling")
local preview = bling.widget.tag_preview

local modkey = "Mod4"

preview.enable {
    show_client_content = true,  -- Whether or not to show the client content
    scale = 0.25,                 -- The scale of the previews compared to the screen
    honor_padding = false,        -- Honor padding when creating widget size
    honor_workarea = true,       -- Honor work area when creating widget size
    placement_fn = function(c)    -- Place the widget using awful.placement (this overrides x & y)
        awful.placement.top_left(c, {
            margins = {
                top = 36,
                left = 30
            }
        })
    end,
    background_widget = wibox.widget {    -- Set a background image (like a wallpaper) for the widget 
        widget = wibox.widget.imagebox,
        image = beautiful.wallpaper,
        horizontal_fit_policy = "fit",
        vertical_fit_policy   = "fit",
    }
}

local taglist_buttons = gears.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t)
	    if client.focus then
	        client.focus:move_to_tag(t)
	    end
	end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
	    if client.focus then
	        client.focus:toggle_tag(t)
	    end
	end),
	awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

return function(s)
    local taglist = awful.widget.taglist {
        screen  = s,
        buttons = taglist_buttons,
        filter  = awful.widget.taglist.filter.all,
        style = {
            shape = gears.shape.circle,
        },
        layout  = {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(6),
        },
        widget_template = {
            {
                id     = "background_inner",
                widget = wibox.container.background,
                shape = gears.shape.circle,
                bg = beautiful.bg_transparent,
                {
                    right  = dpi(6),
                    widget = wibox.container.margin,
                    {
                        id     = "text_role",
                        widget = wibox.widget.textbox,
                        font = "JetBrainsNerdFontMono Regular 14",
                        halign = "center",
                        valign = "center",
                        forced_width = dpi(27),
                    }
                }
            },
            id = "background_role",
            widget = wibox.container.background,
            shape = gears.shape.circle,
            bg = beautiful.bg_transparent,
            create_callback = function(self, c3, _, _)
                self:connect_signal('mouse::enter', function()
                    if #c3:clients() > 0 then
                        awesome.emit_signal("bling::tag_preview::update", c3)
                        awesome.emit_signal("bling::tag_preview::visibility", s, true)
                    end
                    local bg_widget = self:get_children_by_id("background_inner")[1]
                    if bg_widget.bg ~= beautiful.bg_focus then
                        bg_widget.backup     = bg_widget.bg
                        bg_widget.has_backup = true
                    end
                    bg_widget.bg = beautiful.taglist_bg_focus
                end)
                self:connect_signal('mouse::leave', function()
                    if #c3:clients() > 0 then
                        awesome.emit_signal("bling::tag_preview::update", c3)
                        awesome.emit_signal("bling::tag_preview::visibility", s, false)
                    end

                    local bg_widget = self:get_children_by_id("background_inner")[1]
                    if bg_widget.has_backup then bg_widget.bg = bg_widget.backup end
                end)
            end,
        },
    }
    return taglist
end

