#!/bin/bash
###################################################################
#    This script replaces Microsoft's tool for syncing a folder   #
#    with OneDrive. This script runs on the Raspberry Pi Zero W   #
#    and syncs a folder on my laptop with OneDrive.               #
#    Author: Nikos Stylianou, Year: 2021 - 2022                   #
###################################################################

function find_number_of_hosts () {
	temp_file=$(mktemp)
	nmap "local_ip_addr" > $temp_file # Scan whole network. Remember to change this address if the network changes
	txt=$(cat $temp_file)
	byte_off=$(echo $txt | grep -b -o 'hosts up' | awk 'BEGIN {FS=":"}{print $1}')
	start=$(($byte_off - 1))
	hosts_number=$(echo $txt | cut -c$start-$byte_off)
	echo $hosts_number
	rm $temp_file
}

function send_notification_wrapper() {
	if [ $# -ne 1 ]; then
		exit
	fi
	datestamp=$(date +%H:%M:%S)
	message=$datestamp" :  "$1
	python send_notification.py "$message"  >/dev/null 2>/dev/null
}

function sync_local () {
	# Local rclone function. $1 = LOG_LEVEL, $2=LOGGING_DIR, $3=SOURCE_DIR, $4=DEST_DIR

	if [ $# -ne 4 ]; then
		exit
	fi
	send_notification_wrapper "Starting local backup"
	rclone sync --log-level "$1" --log-file "$2/$(date '+%H.%M.%S').local.log" "$3" "$4" -L
	send_notification_wrapper "Finished local backup"
}

function sync_remote () {
	# Remote rclone function. $1 = LOG_LEVEL, $2=LOGGING_DIR, $3=DEST_DIR

	if [ $# -ne 3 ]; then
		exit
	fi
	send_notification_wrapper "Starting remote backup"
	rclone sync --log-level "$1" --log-file "$2/$(date '+%H.%M.%S').onedrive.log" "$3" uth_remote:/UTh -L
	send_notification_wrapper "Finished remote backup"
}

function sync_all () {
	# Local rclone function. $1 = LOG_LEVEL, $2=LOGGING_DIR, $3=SOURCE_DIR, $4=DEST_DIR
	
	if [ $# -ne 4 ]; then
		exit
	fi
	send_notification_wrapper "----------------------------------"
	sync_local $1 $2 $3 $4
	sync_remote $1 $2 $4
	send_notification_wrapper "----------------------------------"
}

function main () {
	SAVEIFS=$IFS

	IFS=$(echo -en "\n\b")
	log_dir="/path/to/Logs/$(date '+%b')/$(date '+%d')"
	mkdir -p "$log_dir"

	# Logging level. See rclone manual for more
	loglevel="INFO"

	# Set directories
	mntpoint="/path/to/mntpoint/"	# Mountpoin folder. With this folder, I check if the folder has been mounted properly.
				# If not, a notification is sent to a smartphone using Telegram app from a simple python script.
	source_dir="/path/to/source/dir/"
	dest_dir="/path/to/dest/dir/"

	# Device recognition
	device_name="DEVICE_NAME"
	ping "$device_name".local -c 15 > /dev/null 2> /dev/null	# Check to see if device is on local network
	device_found=$?
	
	if [ $device_found -eq 0 ]
	then
		if [ $(pidof ngrok) ]; then
			/path/to/scripts/ngrok_service.sh kill	# Kill ngrok daemon if laptop is detected at local network
			send_notification_wrapper "Ngrok connection closed!"
			echo "info: running ngrok service killed" > $log_dir/$(date '+%H.%M.%S').ngrok.log
		fi
		if ! mountpoint -q -- "$source_dir"; then
			ngrok_external_ip=$(/path/to/scripts/ngrok_service.sh start)
			message="The laptop is not connected! Login to: "$message" and fix it!"
			send_notification_wrapper "$message"
			exit
		fi
		sync_"$1" "$loglevel" "$log_dir" "$source_dir" "$dest_dir"
	else # If device hasn't been found, start remote access service aka ngrok unless if I'm at home, in which case I don't want to be open. ( But automate it ofc :) )
		host_num=$(find_number_of_hosts)
		if [ "$host_num" -gt "1" ];then	# If any other device is connected, host_num will be greater than 1 or else it is always 1 as it detects itself.
			if [ $(pidof ngrok) ];then
				/path/to/scripts/ngrok_service.sh kill	# Kill ngrok daemon while other devices present (means that I'm at home).
				send_notification_wrapper "Ngrok connection closed!"
				echo "info: ngrok service is not running as I am home" >"$log_dir/$(date '+%H.%M.%S').ngrok.log"
			fi
			exit
		fi
		if [ $(pidof ngrok) ]; then
			echo "info: ngrok service already running" > "$log_dir/$(date '+%H.%M.%S').ngrok.log"	# If ngrok service is already running, don't start it again
			else
			ngrok_external_ip=$(/path/to/scripts/ngrok_service.sh start)	# Start ngrok service and get listening TCP IP
			send_notification_wrapper "$ngrok_external_ip"
			echo "info: ngrok service started running with ssh external IP $ngrok_external_ip" > "$log_dir/$(date '+%H.%M.%S').ngrok.log"
		fi
	fi
	
	if [ "$1" = "remote" ]; then # Add an exception if the laptop's not home
		sync_"$1" "$loglevel" "$log_dir" "$dest_dir"
	fi

	IFS=$SAVEIFS
}

if [ $(pidof rclone) ];then
	exit
else
	if [ $# -ne 2 ]; then
		echo "Wrong arguments!"
		echo "Usage: $0 <all | remote | local> <directory of the scripts>"
		exit
	fi

	starting_dir="$2"
	cd "$starting_dir"
	main $1
	# input arguments: "local" for local sync, "remote" for syncing, "all" for both local and remote
fi
