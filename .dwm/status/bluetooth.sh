#!/bin/bash

bose="dev_2C_41_A1_CA_4D_19"

#dbus-send --system --type=method_call --print-reply --dest=org.bluez /org/bluez/hci0 org.freedesktop.DBus.Properties.Set string:org.bluez.Adapter1 string:Powered variant:boolean:true
STATE=$(dbus-send --system --type=method_call --print-reply --dest=org.bluez /org/bluez/hci0 org.freedesktop.DBus.Properties.Get string:org.bluez.Adapter1 string:Powered | grep boolean | awk -F' ' '{print $3}')

# check for bose availability
ret=$(dbus-send --system --type=method_call --print-reply --dest=org.bluez /org/bluez/hci0 org.freedesktop.DBus.Introspectable.Introspect)



OUTPUT="BTe: ${STATE}"

echo ${OUTPUT}
