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
	loglevel="INFO"

	# Set directories
	source_dir="/home/nikos/UTh"
	dest_dir="/home/nikos/TOSHIBA DRIVE/Real-Time Backup/UTh"

	# Device recognition
	device_name="HP-250-G7"
	ping "$device_name".local -c 5 > /dev/null 2> /dev/null	# Check to see if device is on local network
	device_found=$?
	
	if [ $device_found -eq 0 ]
	then
		if [ $(pidof ngrok) ]; then
			/home/nikos/.scripts/ngrok_start.sh kill	# Kill ngrok daemon if laptop is detected at local network
			echo "info: running ngrok service killed" > $dir/$(date '+%H.%M.%S').ngrok.log
		fi
		rclone sync --log-level "$loglevel" --log-file "$dir/$(date '+%H.%M.%S').local.log" "$source_dir" "$dest_dir" -L	# Sync laptop folder with remote local backup
		rclone sync --log-level "$loglevel" --log-file "$dir/$(date '+%H.%M.%S').onedrive.log" "$dest_dir" onedrive_uth:/UTh -L	# Sync remote local backup with Onedrive
		else 
		if [ $(pidof ngrok) ]; then
			echo "info: ngrok service already running" > "$dir/$(date '+%H.%M.%S').ngrok.log"	# If ngrok service is already running, don't run again
			else
			get_tcp_ip=$(/home/nikos/.scripts/ngrok_start.sh start)	# Start ngrok service and get listening TCP IP
			/home/nikos/.scripts/pushIP.sh $get_tcp_ip	# Push external IP to personal OneDrive
			echo "info: ngrok service started running with ssh external IP $get_tcp_ip" > "$dir/$(date '+%H.%M.%S').ngrok.log"
		fi
	fi
	
	IFS=$SAVEIFS
}

if [ $(pidof rclone) ];then
	exit
else
	start
fi
