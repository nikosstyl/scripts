#/bin/bash

function ngrok_start () {
	nohup ngrok tcp 22 &> /dev/null &
	sleep 2
	ip=$(ngrok_get_ip)
	echo $ip
}

function ngrok_get_ip () {
	export local temp=$(curl --silent --max-time 10 --connect-timeout 5 --show-error localhost:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p')
	echo $temp
}

function ngrok_kill () {
	kill -s SIGTERM $(pidof ngrok)
}

if [ "$#" -ne 1 ]; then
	echo -e "error: Not enough arguments.\t usage: $0 <start | get_ip | kill>"
	exit
fi

ip=$(ngrok_"$1")
echo $ip
