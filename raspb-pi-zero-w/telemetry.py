import os, time
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
import psutil, subprocess

run_check = ["tailscale", "status"]
TAILSCALE_STOP_STR = "Tailscale is stopped."

def check_tailscale_up() -> int:
    result = subprocess.run(run_check, stdout=subprocess.PIPE)
    result_str = result.stdout.decode("utf-8")

    if TAILSCALE_STOP_STR in result_str:
        return 0
    return 1


token = os.environ.get('INFLUXDB_TOKEN')
org = "Testing"
host = "https://eu-central-1-1.aws.cloud2.influxdata.com"
client = InfluxDBClient(url=host, token=token, org=org)
write_api = client.write_api(write_options=SYNCHRONOUS)

database="RaspberryPi Data"

while True:
    cpu_temp_c = psutil.sensors_temperatures()['cpu_thermal'][0][1]
    cpu_util = psutil.cpu_percent()
    cpu_freq = float(psutil.cpu_freq()[0])
    free_mem = psutil.virtual_memory()[2]
    tailscale_up = check_tailscale_up()

    point = Point("rasbpi").field("temp",cpu_temp_c).field("util",cpu_util).field("freq",cpu_freq).field("ram", free_mem).field("tailscale_up", tailscale_up)
    write_api.write(bucket=database, record=point)

    time.sleep(1.3)
    # print(f"CPU Temp: {cpu_temp_c}°C, CPU Util: {cpu_util}%, CPU Freq: {cpu_freq}", end='\r')
print()
exit()
