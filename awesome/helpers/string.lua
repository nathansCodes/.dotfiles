local gstring = require("gears.string")

local _string = {}

function _string.capitalize(str)
    return str:sub(1, 1):upper() .. str:sub(2):gsub("([ -_].)", function(s) return s:upper() end)
end

return _string
