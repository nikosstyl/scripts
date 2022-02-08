#!/bin/bash

# tmpdir=$(mktemp -d)
# cd $tmpdir
# curl ifconfig.me > ip.txt && rclone copy ip.txt onedrive_uth:/
# cd /home/nikos
# rm -r $tmpdir

function push_ip () {
	tmpdir=$(mktemp -d)
	cd $tmpdir
	echo "Open ssh connection to the following IP: $1" > sshIP.txt
	rclone copy sshIP.txt onedrive_uth:/
	cd /home/nikos
	rm -r $tmpdir
}

if [ "$#" -ne 1 ]; then
	exit
	else 
	push_ip "$1"
fi
