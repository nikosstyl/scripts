############################################
# This script sends a message to 		   #
# my personal Bot. It reads TOKEN and Chat #
# ID from a json file.					   #
# Nikos Stylianou, 2022					   #
############################################

# Usage: python3 send_notification.py "Message to be sent" >/dev/null 2>/dev/null

import requests
import sys
import json

def send_notification(message): 
	creds = open("/etc/telegram_creds.json")
	data =  json.load(creds)

	TOKEN = data["TOKEN"]
	CHAT_ID = data["CHAT_ID"]

	url = f"https://api.telegram.org/bot{TOKEN}/sendMessage?chat_id={CHAT_ID}&text={message}"

	print(requests.get(url).json()) # This sends the message

if __name__ == "__main__":
	if len(sys.argv) != 2:
		print("Wrong arguments")
		print("Usage: python " + sys.argv[0] + " <Message to be sent> (optional: >/dev/null 2>/dev/null)")
		exit()

	send_notification(message=sys.argv[1])