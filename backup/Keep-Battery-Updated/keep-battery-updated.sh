#!/bin/bash
#
# @version      1.0
# @script       keep-battery-updated
# @description  keeps the battery status updated
#
##

DIR="/usr/local/bin/"

while sleep 10; do
    badbattery=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep state: | cut -d ':' -f 2 | xargs)

    case $badbattery in
        discharging)
            badbattery="Discharging"
            ;;
        charging)
            badbattery="Charging"
            ;;
        fully-charged)
            badbattery="Full"
            ;;
    esac

    goodbattery=$(acpi -V | grep Battery | sed -n 1p | cut -d ':' -f 2 | cut -d ',' -f 1 | xargs)

    if [ $badbattery != $goodbattery ]; then
        python3 $DIR/keep-battery-updated.py
    fi
done
