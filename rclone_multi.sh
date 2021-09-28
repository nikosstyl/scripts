#!/bin/bash

if [ $# -ne 1 ]
	then
	echo "No arguments"
	exit
fi
if [ "$1" == 'before' ]
	then
	echo -n "Give Username: "
	read username
	cp /mnt/c/Users/$username/.backhelp/default.location /mnt/c/Users/$username/.backhelp/default.location_temp
	truncate -s 0 /mnt/c/Users/$username/.backhelp/default.location
	echo "C:/Users/$username/.temp_google_drive_uth/UTh.zip" > /mnt/c/Users/$username/.backhelp/default.location
	elif [ "$1" == 'after' ]
	then
	rm /mnt/c/Users/$username/.backhelp/default.location
	mv /mnt/c/Users/$username/.backhelp/default.location_temp /mnt/c/Users/$username/.backhelp/default.location
fi
