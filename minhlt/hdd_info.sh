#!/bin/bash
df -h | grep sd | awk '{print " " $1 " " $2}'
