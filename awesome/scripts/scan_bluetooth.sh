#!/usr/bin/expect -f

set prompt "#"
set address [lindex $argv 0]

spawn bluetoothctl
expect -re $prompt
send "scan on\r"
send_user "\nSleeping\r"
expect eof
