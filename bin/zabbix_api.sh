#!/bin/bash

########## Khai bao bien ##########

HOME=/var/lib/zabbixsrv/mysql
DBNAME="zabbix"

########## Khai bao options ##########

for o; do
    case "${o}" in
        -h)              shift; HOST="${1}"; shift; ;;
        -t)              shift; TYPE="${1}"; shift; ;;
        --help)          echo "-t type|project -n NAME"; ;;
        -*)              echo "Unknown option ${o}.  Try --help."; exit 1; ;;
    esac
done

########## Khai bao hash Object Type ##########

#declare -A ObjectType
#ObjectType=(["1504"]="VM" ["4"]="HardWare Server" ["8"]="Switch");

########## Khai bao functions ##########

get_item_id() {
    mysql $DBNAME -e "select itemid from items as i inner join hosts as h on h.hostid=i.hostid where h.name='$HOST' and i.name='$TYPE usage %';" | tail -1
}

get_value() {
    ITEMID=$1
    mysql $DBNAME -e "select avg(value) from history where itemid=$ITEMID and clock > UNIX_TIMESTAMP(NOW() - INTERVAL 1 DAY) limit 10;" | tail -1
}


########## Main code ##########

ITEMID=`get_item_id`
get_value $ITEMID 
