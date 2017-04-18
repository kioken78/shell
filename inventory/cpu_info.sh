#!/bin/bash
#cat /proc/cpuinfo | grep "model name" | uniq | awk '{print $4 " " $5 " " $6 " " $7 " " $9}'
cat /proc/cpuinfo | grep "model name" | uniq | awk '{print $4 " " $5 " " $6 " " $7 " " $9}' && cat /proc/cpuinfo | grep processor | wc -l | awk '{print "-" " " $1 " " "cores"}'
