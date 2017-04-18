#!/bin/bash

get_option () {
for o; do
	case "${o}" in
        	--command)             shift; OPT_COMMAND="${1}"; shift; echo ${OPT_COMMAND}; ;;
        	--ssh_user)            shift; OPT_SSH_USER="${1}"; shift; ;;
        	--orig_master_host)    shift; OPT_ORIG_MASTER_HOST="${1}"; shift; ;;
        	--orig_master_ip)      shift; OPT_ORIG_MASTER_IP="${1}"; shift; ;;
        	--orig_master_port)    shift; OPT_ORIG_MASTER_PORT="${1}"; shift; ;;
        	--new_master_host)     shift; OPT_NEW_MASTER_HOST="${1}"; shift; ;;
        	--new_master_ip)       shift; OPT_NEW_MASTER_IP="${1}"; shift; ;;
        	--new_master_port)     shift; OPT_NEW_MASTER_PORT="${1}"; shift; ;;
        	--new_master_user)     shift; OPT_NEW_MASTER_USER="${1}"; shift; ;;
        	--new_master_password) shift; OPT_NEW_MASTER_USER_PASS="${1}"; shift; ;;
        	-*)                    echo "Unknown option ${o}. "; exit 1; ;;
      	esac
done
}



