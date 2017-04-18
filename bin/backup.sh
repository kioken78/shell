#!/bin/bash

IP_298_bk_srv="203.162.170.41 203.162.121.110";

for i in ${IP_298_bk_srv}; do
/opt/bin/298_backup.sh `date +"%Y%m%d"` $i;
done
