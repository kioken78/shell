#!/bin/bash
CURTIME=`date +"%Y-%m-%d %H:%M:%S"`
TIMESTAMP=`date +"%Y-%m-%d-%H.%M.%S"`
IP_range=/opt/conf/ip_range
ZABSRV=123.31.21.4
ZABCRE=49d94777f749517275bcc218f5fc66d2
EMAIL=onplay.infra@gmail.com
LOGDIR=/opt/logs
LOGFILE=${LOGDIR}/check_host.log.${TIMESTAMP}

# Define function 
check_host_alive() {
nmap -sP $1 | grep "Nmap done" | grep "1 host up" > /dev/null
STATUS=$?
echo ${STATUS}
if [ ${STATUS} == 0 ]; then
	echo "${CURTIME} : host ${1} up" >> ${LOGFILE}
else
	echo "${CURTIME} : host ${1} down" >> ${LOGFILE}
fi
}

check_host_in_zabbix() {
# check if host is in zabbix or not
curl -H "Content-Type: application/json" -d '{
    "jsonrpc": "2.0",
    "method": "host.exists",
    "params": {
        "host": "'"${1}"'"
    },
    "auth": "'"${ZABCRE}"'",
    "id": 1
}' http://${ZABSRV}/zabbix/api_jsonrpc.php | jsawk 'return this.result'
}

check_host_enable_in_zabbix() {
# Get host status in zabbix, output 0 : Enable, 1 : Disable
curl -H "Content-Type: application/json" -d '{
    "jsonrpc": "2.0",
    "method": "host.getobjects",
    "params": {
        "name": "'"${1}"'"
    },
    "auth": "'"${ZABCRE}"'",
    "id": 1
}' http://${ZABSRV}/zabbix/api_jsonrpc.php | jsawk 'return this.result'  | awk -F"," '{print $5}' | tr -d '"' | awk -F":" '{print $2}'
}

add_host_to_zabbix() {
case $2 in 
	Linux)
curl -H "Content-Type: application/json" -d '{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": "'"${1}"'",
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": "'"${1}"'",
                "dns": "",
                "port": "10050"
            }
        ],
        "groups": [
            {
                "groupid": 2
            }
        ],
        "templates": [
            {
                "templateid": 10001
            },
            {
                "templateid": 10104
            }
        ]
    },
    "auth": "'"${ZABCRE}"'",
    "id": 1
}' http://${ZABSRV}/zabbix/api_jsonrpc.php
echo ""
	;;
	Window)
curl -H "Content-Type: application/json" -d '{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": "'"${1}"'",
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": "'"${1}"'",
                "dns": "",
                "port": "10050"
            }
        ],
        "groups": [
            {
                "groupid": 41
            }
        ],
        "templates": [
            {
                "templateid": 10081
            },
            {
                "templateid": 10104
            }
        ]
    },
    "auth": "'"${ZABCRE}"'",
    "id": 1
}' http://${ZABSRV}/zabbix/api_jsonrpc.php
echo ""		
	;;
	Ping)
curl -H "Content-Type: application/json" -d '{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": "'"${1}"'",
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": "'"${1}"'",
                "dns": "",
                "port": "10050"
            }
        ],
        "groups": [
            {
                "groupid": 42
            }
        ],
        "templates": [
            {
                "templateid": 10104
            }
        ]
    },
    "auth": "'"${ZABCRE}"'",
    "id": 1
}' http://${ZABSRV}/zabbix/api_jsonrpc.php

echo ""
	;;
esac
}

get_hostid_from_zabbix() {
# get hostid from zabbix, input IP, output hostid
curl -H "Content-Type: application/json" -d '{
    "jsonrpc": "2.0",
    "method": "host.getobjects",
    "params": {
        "name": "'"${1}"'"
    },
    "auth": "'"${ZABCRE}"'",
    "id": 1
}' http://${ZABSRV}/zabbix/api_jsonrpc.php | jsawk 'return this.result'  | awk -F"," '{print $2}' | tr -d '"' | awk -F":" '{print $2}'
}

enable_host_in_zabix() {
# enable host in zabix, input hostid.
curl -H "Content-Type: application/json" -d '{
    "jsonrpc": "2.0",
    "method": "host.update",
    "params": {
        "hostid": "'"${1}"'",
        "status": 0
    },
    "auth": "'"${ZABCRE}"'",
    "id": 1
}' http://${ZABSRV}/zabbix/api_jsonrpc.php
echo $?
}

disable_host_in_zabbix() {
# disable host in zabix, input hostid.
curl -H "Content-Type: application/json" -d '{
    "jsonrpc": "2.0",
    "method": "host.update",
    "params": {
        "hostid": "'"${1}"'",
        "status": 1
    },
    "auth": "'"${ZABCRE}"'",
    "id": 1
}' http://${ZABSRV}/zabbix/api_jsonrpc.php
echo $?
}

get_os() {
# get OS type Linux or Window
nmap -O ${1} | grep Running | grep Linux > /dev/null
if [ $? == 0 ]; then
echo Linux
else
echo Window
fi
}

check_port() {
nmap ${1} -PN -p ${2} | grep open > /dev/null
STATUS=$?
echo ${STATUS}
if [ ${STATUS} == 0 ]; then
	echo "${CURTIME} : Port ${2} in host ${1} is open" >> ${LOGFILE};
else 
	echo "${CURTIME} : Port ${2} in host ${1} is not open" >> ${LOGFILE};
fi
}

check_zabbix_agentd() {
ssh $1 "if [ -f /etc/init.d/zabbix-agentd ]; then exit 0; else exit 1;fi"
if [ $? == 0 ]; then
	ps -ef | grep zabbix-agent 
	if [ $? == 0 ]; then
		echo "${CURTIME} : Zabbix agent seem to be installed and running in $1. Check your firewall or zabbix agent configuration" >> ${LOGFILE};
	else
		echo "${CURTIME} : Zabbix agent seem to be installed but not run in $1. Starting zabbix-agent ..." >> ${LOGFILE};
		ssh $1 "/etc/init.d/zabbix-agentd start | tail /var/log/zabbix/zabbix_agentd.log" >> ${LOGFILE};
	fi
else 
	echo "${CURTIME} : Zabbix agent is not installed in $1. Installing zabbix-agent ..." >> ${LOGFILE};
	ssh $1 "yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm; yum install -y zabbix22-agent.x86_64 zabbix22.x86_64";
	scp -r /etc/zabbix/* $1:/etc/zabbix/
	ssh $1 "/etc/init.d/zabbix-agentd start | tail /var/log/zabbix/zabbix_agentd.log" >> ${LOGFILE};
fi
}

send_email_report() {
cat $1 | mail -s "Report of check host on ${CURTIME}" ${EMAIL}
}
# Main code

echo "############ ${CURTIME} Start check host ############" >> ${LOGFILE}

while read line 
do
	IP_LIST=(`echo ${line}`)
	IP_SUFFIX=${IP_LIST[0]}
	START_IP=${IP_LIST[1]}
	END_IP=${IP_LIST[2]}
	for (( i = ${START_IP}; i <= ${END_IP}; i++  )); do
		ALIVE=`check_host_alive ${IP_SUFFIX}${i}`
		if [ ${ALIVE} == 0 ]; then 
			EXIST=`check_host_in_zabbix ${IP_SUFFIX}${i}`
                        PORT22_OPEN=`check_port ${IP_SUFFIX}${i} 22`
                        PORT10050_OPEN=`check_port ${IP_SUFFIX}${i} 10050`
			if [ ${EXIST} == false ]; then
				if [ ${PORT10050_OPEN} == 1 ]; then
                                	if [ ${PORT22_OPEN} == 0 ]; then
                                        	echo "${CURTIME} : Port 22 in host ${IP_SUFFIX}${i} seem open. Starting to check why can not connect to zabbix agent ... "
                                        	check_zabbix_agentd ${IP_SUFFIX}${i}
                                                OS=`get_os ${IP_SUFFIX}${i}`
                                                echo "${CURTIME} : Host ${IP_SUFFIX}${i} is not exist in zabbix. Adding ..." >> ${LOGFILE}
                                                add_host_to_zabbix ${IP_SUFFIX}${i} ${OS} >> ${LOGFILE};
					else
						echo "${CURTIME} : Port 22 in host ${IP_SUFFIX}${i} seem close. I can't do anything, just monitor by pinging"
						add_host_to_zabbix ${IP_SUFFIX}${i} Ping >> ${LOGFILE};
					fi
				else
					OS=`get_os ${IP_SUFFIX}${i}`
					echo "${CURTIME} : Host ${IP_SUFFIX}${i} is not exist in zabbix. Adding ..." >> ${LOGFILE}
					add_host_to_zabbix ${IP_SUFFIX}${i} ${OS} >> ${LOGFILE};
				fi
			else
				ENABLE=`check_host_enable_in_zabbix ${IP_SUFFIX}${i}`
				if [ ${ENABLE} == 1 ]; then
                                	echo "${CURTIME} : Host ${IP_SUFFIX}${i} is exist but not monitord by zabbix. Enabling ..." >> ${LOGFILE}
                                        HOSTID=`get_hostid_from_zabbix ${IP_SUFFIX}${i}`;
                                        enable_host_in_zabix ${HOSTID} >> ${LOGFILE};
                                fi
			fi
		else
			EXIST=`check_host_in_zabbix ${IP_SUFFIX}${i}`
			if [ ${EXIST} == true ]; then
				ENABLE=`check_host_enable_in_zabbix ${IP_SUFFIX}${i}`
				if [ ${ENABLE} == 0 ]; then
					echo "${CURTIME} : Host ${IP_SUFFIX}${i} is offline but still be monitored by zabbix. Disabling ..." >> ${LOGFILE} 
					HOSTID=`get_hostid_from_zabbix ${IP_SUFFIX}${i}`;
					disable_host_in_zabbix ${HOSTID} >> ${LOGFILE}
				fi
			fi
		fi
	done
done < ${IP_range}

echo "############ ${CURTIME} Finish check host ############" >> ${LOGFILE}

#send_email_report ${LOGFILE}
