_G.get_current_internet_connection = function()
    local handle = io.popen("nmcli d | sed -n '3p' | awk '{print $2}'")
    local result = handle:read("*a")
    handle:close()
    return result
end
