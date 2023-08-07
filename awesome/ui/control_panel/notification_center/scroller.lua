-- yanked from github.com/manilarome/the-glorious-dotfiles/blob/master/config/awesome/gnawesome/widget/notif-center/build-notifbox/notifbox-scroller.lua
local awful = require('awful')
local gears = require('gears')

local add_button_event = function(widget)

	widget:buttons(
		gears.table.join(
			awful.button( {}, 4, nil, function()
                if #widget.children == 1 then
                    return
                end
                widget:insert(1, widget.children[#widget.children])
                widget:remove(#widget.children)
            end),
			awful.button( {}, 5, nil, function()
                if #widget.children == 1 then
                    return
                end
                widget:insert(#widget.children + 1, widget.children[1])
                widget:remove(1)
            end)
		)
	)

end

return add_button_event
