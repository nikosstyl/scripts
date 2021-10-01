#!/bin/bash

dir="/path/to/logs/$(date '+%b')/$(date '+%d')"
nMonth=$(date --date='1 day' '+%b')

if [ $nMonth != ${dir:31:3} ]; then
	rm -r ${dir:0:34}
else
	rm -r $dir
fi
