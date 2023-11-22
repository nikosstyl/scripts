# Python version: 3.10.4

from dataclasses import dataclass
from datetime import datetime
import subprocess
import requests
import logging
import json
import sys
import os

ERR_DISK_NOT_MNT_MSG = "Disk is not mounted! Aborting copy!"
START_LOCAL_SYNC_MSG = "Local sync started!"
START_REMOTE_SYNC_MSG = "Remote sync started!"
END_LOCAL_SYNC_MSG = "Local sync stopped!"
END_REMOTE_SYNC_MSG = "Remote sync started!"

RCLONE_PATH = "/path/to/rclone.exe"

LOG_LEVEL = "INFO"
LOG_DIR_PATH = "/path/to/Logs from Sync/" # Root of Log Path directory

SOURCE_DIR = "/path/to/source/dir"
LOCAL_DEST_DIR = "/path/to/destination/dir"
REMOTE_DEST_DIR = "remote_name:/dir"

# A C-like data struct in Python, needed for cleaning Rclone arguments a bit
@dataclass
class rcloneArgsClass:
	local: list
	remote: list

# The folowing class has the necessary informations
# for the log files of the rclone.
class LogFileClass:
	def __init__(self):
		time_now = datetime.now()
		self.FolderPath = LOG_DIR_PATH + time_now.strftime("%b/%d/")
		self.FilePath = self.FolderPath + time_now.strftime("%H.%M.%S") + ".log"
	
		try:
			os.makedirs(self.FolderPath, exist_ok=True)
			self.FileHandler = open(self.FilePath, "w")
		except OSError:
			sys.exit(1)

	def close(self):
		logging.shutdown()
		self.FileHandler.close()

def delete_old_subfolders_recursive(base_path):
    current_time = datetime.now()

    for root, dirs, files in os.walk(base_path, topdown=False):
        for folder_name in dirs:
            folder_path = os.path.join(root, folder_name)

            folder_time = datetime.fromtimestamp(os.path.getmtime(folder_path))
            age = current_time - folder_time

            if age > timedelta(days=7):
                try:
                    shutil.rmtree(folder_path)
                    # print(f"Deleted subfolder: {folder_path}")
                except Exception as e:
                    # print(f"Error deleting subfolder {folder_path}: {e}")
                    logging.warn(f"There was exception while deleteting the folder {folder_path}!\n\t\tReason: {e}")

def checkIfDiskMounted():
	return os.path.isdir(LOCAL_DEST_DIR)


# This is a function that sends information on my Telegram account
def send_notification(message, hasInternet):
	if hasInternet == False:
		return 3

	try: 
		creds = open("/path/to/Telegram_Creds.json")
	except OSError:
		return

	data =  json.load(creds)

	TOKEN = data["TOKEN"]
	CHAT_ID = data["CHAT_ID"]

	url = f"https://api.telegram.org/bot{TOKEN}/sendMessage?chat_id={CHAT_ID}&text={message}"

	requests.get(url).json() # This sends the message

def connected_to_internet(url="https://www.google.com", timeout=5):
	try:
		_ = requests.head(url, timeout=timeout)
		return True
	except requests.ConnectionError:
		logging.warning(" No interned detected! Online sync not available!")
		return False


def main():
	LogFile = LogFileClass()
	logging.basicConfig(filename=LogFile.FilePath, filemode="a", level=logging.INFO)

	hasInternet = connected_to_internet()

	if checkIfDiskMounted() == False:
		send_notification(ERR_DISK_NOT_MNT_MSG, hasInternet)
		logging.error(ERR_DISK_NOT_MNT_MSG)
		LogFile.close()
		sys.exit(2)

	rcloneArgs = rcloneArgsClass(local=[RCLONE_PATH, "sync", SOURCE_DIR, LOCAL_DEST_DIR, "-L", "--log-level", LOG_LEVEL, "--log-file", LogFile.FilePath],
								remote=[RCLONE_PATH, "sync", SOURCE_DIR, REMOTE_DEST_DIR, "-L", "--log-level", LOG_LEVEL, "--log-file", LogFile.FilePath])

	logging.info(START_LOCAL_SYNC_MSG)
	pr1 = subprocess.Popen(rcloneArgs.local, universal_newlines=True)
	pr1.wait()
	logging.info(END_LOCAL_SYNC_MSG)

	if hasInternet == True:
		logging.info(START_REMOTE_SYNC_MSG)
		pr2 = subprocess.Popen(rcloneArgs.remote, universal_newlines=True)
		pr2.wait()
		logging.info(END_REMOTE_SYNC_MSG)


	LogFile.close()
	delete_old_subfolders_recursive(LOG_DIR_PATH)
	sys.exit(0)

if __name__ == "__main__":
	main()
