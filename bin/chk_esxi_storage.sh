#!/bin/bash
host=$1
datastore=$2
user=root
pass=12345a@

/opt/bin/conn2esxi.sh $user $host $pass | grep VMFS | grep "$datastore" |awk '{print $5}'
