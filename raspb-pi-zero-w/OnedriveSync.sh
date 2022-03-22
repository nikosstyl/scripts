#!/bin/bash
###################################################################
#    This script replaces Microsoft's tool for syncing a folder   #
#    with OneDrive. This script runs on the Raspberry Pi Zero W   #
#    and syncs a folder on my laptop with OneDrive.               #
#    Author: Nikos Stylianou, Year: 2021                          #
###################################################################

function sync_local () {
	# Local rclone function. $1 = LOG_LEVEL, $2=LOGGING_DIR, $3=SOURCE_DIR, $4=DEST_DIR

	if [ $# -ne 4 ]; then
		exit
	fi
	rclone sync --log-level "$1" --log-file "$2/$(date '+%H.%M.%S').local.log" "$3" "$4" -L
}

function sync_remote () {
	# Remote rclone function. $1 = LOG_LEVEL, $2=LOGGING_DIR, $3=DEST_DIR

	if [ $# -ne 3 ]; then
		exit
	fi
	rclone sync --log-level "$1" --log-file "$2/$(date '+%H.%M.%S').onedrive.log" "$3" onedrive_uth:/UTh -L
}

function sync_all () {
	# Local rclone function. $1 = LOG_LEVEL, $2=LOGGING_DIR, $3=SOURCE_DIR, $4=DEST_DIR
	
	if [ $# -ne 4 ]; then
		exit
	fi
	sync_local $1 $2 $3 $4
	sync_remote $1 $2 $4
}

function start () {
	SAVEIFS=$IFS

	IFS=$(echo -en "\n\b")
	log_dir="/home/nikos/Logs/$(date '+%b')/$(date '+%d')"
	mkdir -p "$log_dir"

	# Logging level. See rclone manual for more
	loglevel="INFO"

	# Set directories
	mntpoint="/mnt/laptop"	# Mountpoin folder. With this folder, I check if the folder has been mounted properly.
							# If not, a notification is sent to a smartphone using IFTTT app from a simple python script.
	source_dir="/home/nikos/UTh"	# Self-explanatory
	dest_dir="/home/nikos/TOSHIBA DRIVE/Real-Time Backup/UTh"	# Self-explanatory

	# Device recognition
	device_name="HP-250-G7"
	ping "$device_name".local -c 15 > /dev/null 2> /dev/null	# Check to see if device is on local network
	device_found=$?
	
	if [ $device_found -eq 0 ]
	then
		if [ $(pidof ngrok) ]; then
			/home/nikos/.scripts/ngrok_service.sh kill	# Kill ngrok daemon if laptop is detected at local network
			/home/nikos/.scripts/pushIP.sh remove	# Remove ip text file from personal Onedrive
			echo "info: running ngrok service killed" > $log_dir/$(date '+%H.%M.%S').ngrok.log
		fi
		if ! mountpoint -q -- "$source_dir"; then
			python /home/nikos/.scripts/send_notification.py $(/home/nikos/.scripts/ngrok_service.sh start)	# See line 48
			/home/nikos/.scripts/pushIP.sh push $(/home/nikos/.scripts/ngrok_service.sh get_ip)
			exit
		fi
		sync_"$1" "$loglevel" "$log_dir" "$source_dir" "$dest_dir"
	else	# If device hasn't been found, start remote access service aka ngrok
		if [ $(pidof ngrok) ]; then
			echo "info: ngrok service already running" > "$log_dir/$(date '+%H.%M.%S').ngrok.log"	# If ngrok service is already running, don't start it again
			else
			get_tcp_ip=$(/home/nikos/.scripts/ngrok_service.sh start)	# Start ngrok service and get listening TCP IP
			/home/nikos/.scripts/pushIP.sh push $get_tcp_ip	# Push external IP to personal OneDrive
			echo "info: ngrok service started running with ssh external IP $get_tcp_ip" > "$log_dir/$(date '+%H.%M.%S').ngrok.log"
		fi
	fi
	
	if [ "$1" = "remote" ]; then
		sync_"$1" "$loglevel" "$log_dir" "$dest_dir"	# This line is actually ment to be executed while not being home.
	fi

	IFS=$SAVEIFS
}

if [ $(pidof rclone) ];then
	exit
else
	if [ $# -ne 1 ]; then
		exit
	fi
	start $1
fi
