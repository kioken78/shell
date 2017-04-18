#!/bin/bash

########## Khai bao bien ##########

HOME=/var/lib/zabbixsrv/mysql
DBNAME="racktablesdb"

########## Khai bao options ##########

for o; do
    case "${o}" in
        -t)              shift; TYPE="${1}"; shift; ;;
        -n)              shift; NAME="${1}"; shift; ;;
        --help)          echo "-t type|project -n NAME"; ;;
        -*)              echo "Unknown option ${o}.  Try --help."; exit 1; ;;
    esac
done

########## Khai bao hash Object Type ##########

declare -A ObjectType
ObjectType=(["1504"]="VM" ["4"]="HardWare Server" ["8"]="Switch");

########## Khai bao functions ##########

chk_host_type() {
    TypeID=`mysql $DBNAME -e "select objtype_id from Object where name='$NAME'\G" | tail -1 | awk '{print $2}'`
    echo "${ObjectType["$TypeID"]}";
}



chk_host_project() {
    mysql $DBNAME -e "select t1.tag from TagTree as t1 INNER JOIN TagStorage as t2 INNER JOIN Object as t3 ON t1.id=t2.tag_id AND t2.entity_id=t3.id where t3.name='$NAME'\G" | grep 2_ | awk '{print $2}'| awk -F"_" '{print $2" "$3}'
}

chk_rack() {
    rack_id=`mysql $DBNAME -e "select distinct(rp.rack_id) from RackSpace as rp INNER JOIN RackObject as ro on rp.object_id=ro.id where ro.name='$NAME'"`
    if [[ -z $rack_id ]]; then
        container_id=`mysql $DBNAME -e "select parent_entity_id from EntityLink as en INNER JOIN RackObject as ro on ro.id=en.child_entity_id where ro.name='$NAME'" | tail -1`;
        rack_id=`mysql $DBNAME -e "select distinct(rp.rack_id) from RackSpace as rp INNER JOIN RackObject as ro on rp.object_id=ro.id where ro.id='$container_id'" | tail -1`
        mysql $DBNAME -e "select name from Rack where id='$rack_id'" | tail -1
    else
        mysql $DBNAME -e "select name from Rack where id='$rack_id'" | tail -1
    fi
}

chk_host_avaiable() {
    mysql $DBNAME -e ""

}

    


########## Main code ##########

case $TYPE in 
    type)
    chk_host_type
    ;;
    project)
    chk_host_project
    ;;
    rack)
    chk_rack
    ;;
    location)
    chk_rack | awk -F"-" '{print $2}'
    ;;
    *)
    echo "We don't have this option. Please try --help";   
    ;;
esac
