#!/bin/bash
uri=http://wss.azgame.us/Service02/OnplaySystem.asmx/GetOracleConnectionInfo

get_info() {
curl $uri | tr -d '"'
}

if [ $1 == "current" ]; then
	get_info | awk -F"," '{print $3}' | awk -F":" '{print $3}'
else
	get_info | awk -F"," '{print $4}' | awk -F":" '{print $2}'
fi

