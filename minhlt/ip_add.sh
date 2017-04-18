#!/bin/bash
ifconfig | grep "inet addr" | grep -vv 127.0.0.1 | grep -vv 10.10 | awk '{print $2}' | awk -F: '{print $2}'
