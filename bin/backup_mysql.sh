#!/bin/bash

TIMESTAMP=`date +%Y%m%d`
BACKUP_DIR="/data/backup/${TIMESTAMP}"
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
HOME=~/mysql

mkdir -p $BACKUP_DIR
# get list of DB
databases=`$MYSQL -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|innodb|performance_schema)"`
# stop slave before backup
$MYSQL -e "stop slave;"

# backup db
for db in $databases; do
echo $db
$MYSQLDUMP --force --opt --databases $db | gzip > "$BACKUP_DIR/$db.gz"
done

# start slave
$MYSQL -e "start slave;"
