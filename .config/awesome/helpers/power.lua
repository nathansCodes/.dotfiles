local awful = require("awful")

local power = {}

function power.shutdown()
    require("ui.theme.themer").revert(function()
        awful.spawn("systemctl poweroff")
    end)
end
function power.reboot()
    require("ui.theme.themer").revert(function()
        awful.spawn("systemctl reboot")
    end)
end
function power.lock() awesome.emit_signal("lockscreen::lock") end
function power.logout() awesome.quit() end

return power
