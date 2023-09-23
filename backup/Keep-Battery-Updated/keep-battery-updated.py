#!/usr/bin/env python
# -*- coding: utf-8 -*-

import dbus


def run_dbus_method(bus_type, obj, path, interface, method, arg):
    if bus_type == "session":
        bus = dbus.SessionBus()
    elif bus_type == "system":
        bus = dbus.SystemBus()
    else:
        return None

    proxy = bus.get_object(obj, path)
    dbus_method = proxy.get_dbus_method(method, interface)

    return dbus_method(arg) if arg else dbus_method()


def find_battery_path():
    call = ['system', 'org.freedesktop.UPower',
            '/org/freedesktop/UPower', 'org.freedesktop.UPower',
            'EnumerateDevices', None]
    devices = run_dbus_method(*call)
    for i in devices:
        if 'BAT' in i:
            return str(i)
    return None


def main():
    bat_path = find_battery_path()
    call = ['system', 'org.freedesktop.UPower',
            bat_path, 'org.freedesktop.UPower.Device',
            'Refresh', None]

    run_dbus_method(*call)


if __name__ == '__main__':
    main()