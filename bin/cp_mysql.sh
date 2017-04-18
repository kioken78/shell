#!/bin/bash

DATE_REMOVE=`date -d '6 day ago' +%Y%m%d`
HOST=`hostname`

LOCAL_LOG_DIR="/data/backup/"
REMOTE_LOG_DIR="/data/mysql/"
REMOTESRV="fluent02"

get_cp_dir() {
for i in `find $LOCAL_LOG_DIR -type d | awk -F"/" '{print $4}'`; do 
	if [ "$i" -lt $DATE_REMOVE ]; then
		echo $LOCAL_LOG_DIR$i;
	fi
done
}

cp_data() {
rsync -avz ${1} ${REMOTESRV}:${REMOTE_LOG_DIR}${HOST}/
status=$?
}

rm_old_data() {
if [ $status == 0 ]; then 
	rm -rf $i	
fi
}

for i in `get_cp_dir`; do 
	cp_data $i
	rm_old_data $i
done
