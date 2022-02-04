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

	# Logging level. See rclone manual for more
	loglevel="NOTICE"

	# Set directories
	source_dir="/home/nikos/UTh"
	dest_dir="/home/nikos/TOSHIBA DRIVE/Real-Time Backup/UTh"

	# Device recognition
	device_name="MyDevice"
	ping "$device_name".local -c 5 > /dev/null 2> /dev/null
	stat=$?
	
	if [ $statt -ne 0 ]  
	then
		mflag=1
	else 
		mflag=0
	fi
	if [ $mflag -eq 0 ]
	then
		rclone sync --log-level "$loglevel" --log-file "$dir/$(date '+%H.%M.%S').local.log" "$source_dir" "$dest_dir" -L
	fi
	rclone sync --log-level "$loglevel" --log-file "$dir/$(date '+%H.%M.%S').onedrive.log" "$dest_dir" onedrive_uth:/UTh -L

	IFS=$SAVEIFS
}

if [ $(pidof rclone) ];then
	exit
else
	start
fi
