-- this is unused and unfinished. `bluetoothctl scan on` does nothing on my system for some reason
local gears = require("gears")
local awful = require("awful")

local capi = { awesome = awesome }

local check_ended = false
local function add_device(line)
    capi.awesome.emit_signal("bluetooth::devices::update_start")
    check_ended = false
    local name = line:sub(26)
    local mac_address = line:sub(8, 24)

    if gears.string.startswith(name, "Manufacturer") then return end

    awful.spawn.easy_async("bluetoothctl info " .. mac_address, function(out)
        local icon = string.sub(out:match("Icon: [%w%-]*") or "", 7)
        local paired = out:match("Paired: yes") ~= nil
        local bonded = out:match("Bonded: yes") ~= nil
        local trusted = out:match("Trusted: yes") ~= nil
        local blocked = out:match("Blocked: yes") ~= nil
        local connected = out:match("Connected: yes") ~= nil

        capi.awesome.emit_signal("bluetooth::devices::add", {
            name = name,
            mac_address = mac_address,
            icon = icon,
            paired = paired,
            bonded = bonded,
            trusted = trusted,
            blocked = blocked,
            connected = connected,
        })
        if check_ended then
            capi.awesome.emit_signal("bluetooth::devices::update_end")
            check_ended = false
        end
    end)
end

local function update_bluetooth_devices()
    capi.awesome.emit_signal("bluetooth::devices::blank")
    awful.spawn.with_line_callback("bluetoothctl devices", {
        stdout = function(out)
            add_device(out)
        end,
        output_done = function()
            check_ended = true
        end
    })
end

awful.spawn("bluetoothctl scan on")

gears.timer {
    autostart = true,
    call_now = true,
    timeout = 5,
    callback = function()
        update_bluetooth_devices()
    end,
}
