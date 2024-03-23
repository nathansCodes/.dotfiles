local awful = require("awful")

local capi = { awesome = awesome }

local power = {}

function power.shutdown() awful.spawn("systemctl poweroff") end
function power.reboot() awful.spawn("systemctl reboot") end
function power.lock() capi.awesome.emit_signal("lockscreen::lock") end
function power.logout() capi.awesome.quit() end

return power
