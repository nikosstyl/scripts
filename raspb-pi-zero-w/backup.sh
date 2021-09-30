#!/bin/bash
SAVEIFS=$IFS
dir="/path/to/log/$(date '+%b')/$(date '+%d')"
mkdir -p "$dir"
logName="$dir/$(date '+%H.%M.%S').log"

stat=$(nbtscan 192.168.1.1-10 | grep <NetBIOS name of PC>)
statt=$?
exstat=${stat%<NetBIOS name of PC>*}
if [ $statt -ne 0 ]  
then
	echo "Haven't found any device. Aborting!" > "$logName"
	exit
fi
rclone sync --log-level INFO --log-file "$logName" /path/to/source /path/to/destination
IFS=$SAVEIFS
