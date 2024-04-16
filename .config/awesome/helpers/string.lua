local gstring = require("gears.string")

local _string = {}

function _string.upper_first_letter(str)
    return str:sub(1, 1):upper() .. str:sub(2):gsub("([ -_].)", function(s) return s:upper() end)
end

function _string.lower_first_letter(str)
    return str:sub(1, 1):lower() .. str:sub(2):gsub("([ -_].)", function(s) return s:lower() end)
end

local function switch_case(str)
    if str:match("[a-z]") then
        str = str:upper()
    else
        str = str:lower()
    end
end

function _string.switch_case_first_letter(str)
    local first_letter = switch_case(str:sub(1,1))

    return first_letter .. str:sub(2):gsub("([ -_].)", function(s) return switch_case(s) end)
end

return _string
