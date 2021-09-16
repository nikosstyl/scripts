#!/bin/bash

if [ $# -ne 1 ]
	then
	exit
fi
if [ "$1" == 'before' ]
	then
	cp /mnt/c/Users/Nikos\ Stylianou/.backhelp/default.location /mnt/c/Users/Nikos\ Stylianou/.backhelp/default.location_temp
	truncate -s 0 /mnt/c/Users/Nikos\ Stylianou/.backhelp/default.location
	echo "C:/Users/Nikos Stylianou/.temp_google_drive_uth/UTh.zip" > /mnt/c/Users/Nikos\ Stylianou/.backhelp/default.location
	elif [ "$1" == 'after' ]
	then
	rm /mnt/c/Users/Nikos\ Stylianou/.backhelp/default.location
	mv /mnt/c/Users/Nikos\ Stylianou/.backhelp/default.location_temp /mnt/c/Users/Nikos\ Stylianou/.backhelp/default.location
fi
