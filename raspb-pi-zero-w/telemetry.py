import os, time
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
import psutil

token = os.environ.get('INFLUXDB_TOKEN') # Must be given in the systemd
org = "Testing"
host = "https://eu-central-1-1.aws.cloud2.influxdata.com"
client = InfluxDBClient(url=host, token=token, org=org)
write_api = client.write_api(write_options=SYNCHRONOUS)

influxBucket="rpiData"

def get_wifi_signal():
    with open("/proc/net/wireless", "r") as f:
        lines = f.readlines()
        if len(lines) > 2:
            return [int(lines[2].split()[3].replace('.', '')), int(lines[2].split()[2].replace('.', ''))]
            # returns -db and link quality
    return 0


def get_system_metrics():
    with open('/proc/uptime', 'r') as f:
        uptime_seconds = float(f.readline().split()[0])

    return {
        "temp": psutil.sensors_temperatures()['cpu_thermal'][0][1],
        "util": psutil.cpu_percent(),
        "freq": float(psutil.cpu_freq()[0]),
        "ram": psutil.virtual_memory()[2],
        "uptime": int(uptime_seconds),
        "avg_load_1m": os.getloadavg()[0],
        "wifi_db": get_wifi_signal()[0],
        "wifi_quality": get_wifi_signal()[1],
    }

while True:
    metrics = get_system_metrics()

    point = Point("rasbpi")
    for key,value in metrics.items():
        point.field(key, value)
    write_api.write(bucket=influxBucket, record=point)

    time.sleep(5)
    # print(f"\033[2K\rCPU Temp: {cpu_temp_c}°C, CPU Util: {cpu_util}%, CPU Freq: {cpu_freq}, Uptime: {get_uptime()}", end='')
print()
exit()
