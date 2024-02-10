local gears = require("gears")

local _time = {}

function _time.time_object(args)
    local ret = {
        hour = args.hour or 0,
        minute = args.minute or 0,
        second = args.second or 0,
        mt = {},
    }

    function ret.mt:__sub(a, b)
        a.hour = a.hour - b.hour
        a.minute = a.minute - b.minue
        a.second = a.second - b.second

        if a.hour < 0 then
            a.minute = a.minute + (-a.hour * 60)

            if a.minute >= 60 then
                a.hour = a.hour + math.floor(a.minute / 60)
            end
        end

        if a.minute < 0 then
            a.second = a.second + (-a.minute * 60)

            if a.second >= 60 then
                a.minute = a.minute + math.floor(a.second / 60)
            end
        end
    end

    function ret.mt:__add(a, b)
        a.hour = a.hour + b.hour
        a.minute = a.minute + b.minue
        a.second = a.second + b.second

        if a.second >= 60 then
            a.minute = a.minute + math.floor(a.second / 60)
        end

        if a.minute >= 60 then
            a.hour = a.hour + math.floor(a.minute / 60)
        end
    end

    return setmetatable(ret, ret.mt)
end

function _time.from_seconds(sec)
    local hour = math.floor(sec / 3600)
    local min = math.floor(sec / 60) - (hour * 60)
    local sec = sec - hour*3600 - min*60
    return _time.time_object {
        hour = hour,
        minute = min,
        second = sec,
    }
end

function _time.get_time()
    return _time.time_object {
        hour = tonumber(os.date("%H")),
        minute = tonumber(os.date("%M")),
        second = tonumber(os.date("%S")),
    }
end

function _time.timer(args)
    local start_time = _time.get_time()

    local timeout_str = tostring(args.clock) or "10s"
    local timeout = 10

    if gears.string.endswith(timeout_str, "s") then
        timeout = tonumber(string.sub(timeout_str, 1, -2))
    elseif gears.string.endswith(timeout_str, "m") then
        timeout = tonumber(string.sub(timeout_str, 1, -2)) * 60
    elseif gears.string.endswith(timeout_str, "h") then
        timeout = tonumber(string.sub(timeout_str, 1, -2)) * 3600
    end

    return gears.timer {
        timeout = timeout,
        start_now = args.start_now or true,
        autostart = args.autostart or true,
        callback = function()
            local time = _time.get_time()
            if args.relative then
                time = time - start_time
            end

            args.callback(time)
        end,
    }
end

return _time
