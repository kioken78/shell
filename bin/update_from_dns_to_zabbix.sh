#!/bin/bash

for o; do
        case "${o}" in
        -d)              shift; DOMAIN="${1}"; shift; ;;
        --help)          echo "-d DOMAIN_NAME"; ;;
        -*)              echo "Unknown option ${o}.  Try --help."; exit 1; ;;
        esac
done

# Function define 
check_dns_name() {
dig s10.ahtq.vn +multiline +noall +answer
}

# main code


