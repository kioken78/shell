#!/usr/bin/expect -f
set user [lindex $argv 0]
set host [lindex $argv 1]
set pass [lindex $argv 2]

spawn ssh $user@$host
expect -re "Password:"
send "$pass\n"
expect -re "information."
send "df -h\n"
expect -re "vfat"
send "exit\n"
