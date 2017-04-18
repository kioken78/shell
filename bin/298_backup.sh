#!/bin/bash

BACKDIR=/backup/298
USERNAME=backup
PASSWD=!QAZxdr5

DAY=$1
SERVER=$2

check_dir() {
if [ ! -d ${1} ] ; then
    mkdir -p ${1} || exit 1
fi
}

get_data_ftp() {
ftp -in <<EOF
open $SERVER
user $USERNAME $PASSWD
binary
mget *$DAY*
close 
bye
EOF
}

check_dir ${BACKDIR}/${SERVER}
cd ${BACKDIR}/${SERVER}
get_data_ftp
