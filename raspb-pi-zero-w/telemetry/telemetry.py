import os, time, psutil, yaml
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS


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

with open("telemetry_cfg.yaml", "r") as f:
    config = yaml.safe_load(f)

token = os.environ.get('INFLUXDB_TOKEN') # Must be given in the systemd
org = config["InfluxDB"]["org"]
host = config["InfluxDB"]["host"]
influxBucket = config["InfluxDB"]["bucket"]
pointName = config["InfluxDB"]["point_name"]
client = InfluxDBClient(url=host, token=token, org=org)
write_api = client.write_api(write_options=SYNCHRONOUS)

while True:
    metrics = get_system_metrics()

    point = Point(pointName)
    for key,value in metrics.items():
        point.field(key, value)
    write_api.write(bucket=influxBucket, record=point)

    time.sleep(5)
print()
exit()
