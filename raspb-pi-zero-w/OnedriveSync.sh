#!/bin/bash
###################################################################
#    This script replaces Microsoft's tool for syncing a folder   #
#    with OneDrive. This script runs on the Raspberry Pi Zero W   #
#    and syncs a folder on my laptop with OneDrive.               #
#    Author: Nikos Stylianou, Year: 2021                          #
###################################################################

function start () {
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	dir="/home/nikos/Logs/$(date '+%b')/$(date '+%d')"
	mkdir -p "$dir"
	# logName="$dir/$(date '+%H.%M.%S').log"

	stat=$(nbtscan 192.168.1.1-10 | grep HP-250-G7)
	statt=$?
	# exstat=${stat%HP-250-G7*}
	if [ $statt -ne 0 ]  
	then
		mflag=1
	else 
		mflag=0
	fi
	if [ $mflag -eq 0 ]
	then
		rclone sync --log-level INFO --log-file "$dir/$(date '+%H.%M.%S').local.log" /home/nikos/UTh "/home/nikos/TOSHIBA DRIVE/Real-Time Backup/UTh" -L
	fi
	rclone sync --log-level INFO --log-file "$dir/$(date '+%H.%M.%S').onedrive.log" "/home/nikos/TOSHIBA DRIVE/Real-Time Backup/UTh" onedrive_uth:/UTh -L
	IFS=$SAVEIFS
}

if [ $(pidof rclone) ];then
	exit
else
	start
fi
