#!/bin/bash
set -uo pipefail

LOGPATH='/var/log/patroni/'

function tick_etcd_leader(){
        
}

function on_role_change_handler() {
	local role=$1
	local cluster=$2
	local detect_role=$(/pg/bin/pg-role)

   case ${role} in
	primary | p | master | m | leader | l)
		
		;;
	standby | s | replica | r | slave)
	    
		;;
	*)
		exit 1
		;;
	esac

	psql -Atqwc 'CHECKPOINT;CHECKPOINT;'
}

function on_stop_handler() {
	local role=$1
	local cluster=$2
	exit 0
}

function on_start_handler() {
	local role=$1
	local cluster=$2
	exit 0
}

function main() {
	local event=$1
	local role=$2
	local cluster=$3

    printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")] event=${event}, role=${role}  \033[0m\n" >>$LOGPATH/callback.log
	# unify role to primary & replica

	case ${event} in
	on_stop)
		on_stop_handler ${role} ${cluster}
		;;
	on_start)
		on_start_handler ${role} ${cluster}
		;;
	on_role_change)
		on_role_change_handler ${role} ${cluster}
		;;
	*)
		usage
		;;
	esac
    printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")]\033[0m\n" >>$LOGPATH/callback.log
}

main $@
