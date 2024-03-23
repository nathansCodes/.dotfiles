local checkers = {}

function checkers.number_negative(input)
    local num = tonumber(input)
    return num ~= nil and num<=0 or input == ""
end

function checkers.number_positive(input)
    local num = tonumber(input)
    return num ~= nil and num>=0 or input == ""
end

function checkers.number(input)
    local num = tonumber(input)
    return num ~= nil or input == ""
end

function checkers.non_empty(input)
    return input:len() > 0
end

return checkers
