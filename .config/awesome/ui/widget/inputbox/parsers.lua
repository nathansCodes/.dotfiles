local parsers = {}

function parsers.number(input)
    return tostring(tonumber(input))
end

return parsers
