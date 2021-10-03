#!/bin/bash

dir="/path/to/Logs/$(date '+%b')/$(date '+%d')"
mkdir -p $dir
rclone sync --log-level INFO --log-file "$dir/$(date '+%H.%M.%S'.log)" /path/to/source remote:dest/
