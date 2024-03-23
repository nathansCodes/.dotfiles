local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local rubato = require("modules.rubato")
local bling = require("modules.bling")

local capi = { client = client, awesome = awesome }

local super = "Mod4"

local taglist_buttons = gears.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ super }, 1, function(t)
	    if capi.client.focus then
	        capi.client.focus:move_to_tag(t)
	    end
	end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ super }, 3, function(t)
	    if capi.client.focus then
	        capi.client.focus:toggle_tag(t)
	    end
	end),
	awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local focused_width = dpi(80)
local occupied_width = dpi(50)
local empty_width = dpi(30)

return function(s)
    local preview = bling.widget.tag_preview
    preview.enable {
        show_client_content = true,
        scale = 0.25,
        honor_padding = false,
        honor_workarea = true,
        placement_fn = function(c)
            awful.placement.top_left(c, {
                margins = {
                    top = dpi(36),
                    left = dpi(30)
                }
            })
        end,
        background_widget = wibox.widget {
            widget = wibox.widget.imagebox,
            image = beautiful.wallpaper,
            horizontal_fit_policy = "fit",
            vertical_fit_policy   = "fit",
        }
    }

    local taglist = awful.widget.taglist {
        screen  = s,
        buttons = taglist_buttons,
        filter  = awful.widget.taglist.filter.all,
        style = {
            shape = gears.shape.rounded_bar,
        },
        layout  = {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(10),
        },
        widget_template = {
            id     = "background_role",
            widget = wibox.container.background,
            shape  = gears.shape.rounded_bar,
            fg     = beautiful.bg_normal,
            {
                id     = "margins",
                widget = wibox.container.margin,
                margins   = dpi(4),
                {
                    widget = wibox.container.place,
                    {
                        layout  = wibox.layout.fixed.horizontal,
                        spacing = dpi(4),
                        {
                            id     = "icon",
                            widget = wibox.widget.textbox,
                            font   = beautiful.icon_font .. "16",
                            halign = "center",
                            valign = "center",
                        },
                        {
                            id     = "text_role",
                            widget = wibox.widget.textbox,
                            font   = beautiful.font .. "SemiBold 11",
                            halign = "center",
                            valign = "center",
                        },
                    }
                }
            },
            create_callback = function(self, t, _, _)
                -- set icon
                local icon = self:get_children_by_id("icon")[1]
                icon:set_text(t.icon)

                self.animator = rubato.timed {
                    duration = 0.5,
                    easing = rubato.linear,
                    pos = empty_width,
                    subscribed = function(pos)
                        self:get_children_by_id("background_role")[1]:set_forced_width(pos)
                        local opacity = (pos-occupied_width)/(focused_width-occupied_width)
                        self:get_children_by_id("text_role")[1]:set_opacity(opacity)

                        -- just some math I figured out in desmos
                        -- so that I don't need a second animator :)
                        local left_margin = math.min(0.46 * (pos-30) + 3.5, 0.424 * (80 - pos))
                        self:get_children_by_id("margins")[1]:set_left(left_margin)
                    end,
                }

                -- update animator target
                self.update = function()
                    if t.selected then
                        self.animator.target = focused_width
                    elseif #t:clients() > 0 then
                        self.animator.target = occupied_width
                    else
                        self.animator.target = empty_width
                    end
                end
                self.update()

                -- tag preview stuff
                self:connect_signal('mouse::enter', function()
                    if #t:clients() > 0 then
                        capi.awesome.emit_signal("bling::tag_preview::update", t)
                        capi.awesome.emit_signal("bling::tag_preview::visibility", s, true)
                    end
                end)
                self:connect_signal('mouse::leave', function()
                    capi.awesome.emit_signal("bling::tag_preview::visibility", s, false)
                end)
            end,
            update_callback = function(self, _, _, _)
                self.update()
            end,
        },
    }
    return taglist
end

