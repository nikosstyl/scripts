import sys
from ifttt_webhook import IftttWebhook

if len(sys.argv) != 2:
	exit()

key_l='/etc/ifttt_key.conf'
ifttt=IftttWebhook(key_l)
ifttt.trigger('laptop_not_found', value1=sys.argv[1])