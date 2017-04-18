#!/bin/bash
export PATH=$PATH:/usr/sbin:/sbin

SRCHOST=203.162.170.3
SET_BLACKLIST_VN=blacklist_vn
SET_BLACKLIST_INT=blacklist_int

CONFDIR=/opt/conf
WHITELIST=${CONFDIR}/whitelist

URI=http://${SRCHOST}/b_list/

### Function predifined ###
create_ipset() {
ipset create blacklist_vn hash:ip
ipset create blacklist_int hash:ip
}
create_iptables_rules() {
iptables -I INPUT -m set --match-set blacklist_vn src -j DROP
iptables -I INPUT -m set --match-set blacklist_int src -j DROP
iptables -I FORWARD -m set --match-set blacklist_vn src -j DROP
iptables -I FORWARD -m set --match-set blacklist_int src -j DROP
}

whitelist() {
GREYIP=$1
grep ${GREYIP} ${WHITELIST} > /dev/null
if [ $? != 0 ]; then
    echo $GREYIP
fi
}

### Check ipset exist or not? If not, create ###
ipsetcount=`ipset list | grep Name  | grep blacklist  | wc -l`

if [ $ipsetcount -lt 2 ]; then
    create_ipset;
fi

### Check if iptables rules exist or not? If not, create ###
iptablescount=`iptables-save | grep blacklist | wc -l`

if [ $iptablescount -lt 4 ]; then
    create_iptables_rules
fi

### update set ###
ipset flush ${SET_BLACKLIST_VN}
for i in `curl ${URI}/${SET_BLACKLIST_VN} 2> /dev/null`; do
    BLACKVNIP=`whitelist $i`
    if [ -n ${BLACKVNIP} ]; then
        ipset -A $SET_BLACKLIST_VN ${BLACKVNIP} 2> /dev/null
    fi
done

ipset flush ${SET_BLACKLIST_INT}
for i in `curl ${URI}/${SET_BLACKLIST_INT} 2> /dev/null`; do
    BLACKINTIP=`whitelist $i`
    if [ -n ${BLACKINTIP} ]; then
        ipset -A $SET_BLACKLIST_INT ${BLACKINTIP} 2> /dev/null
    fi
done


