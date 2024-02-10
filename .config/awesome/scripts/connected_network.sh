nmcli --get-values in-use,ssid,signal d wifi | grep -Po '(?<=\*:).*'
