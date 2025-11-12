#!/bin/bash
# sink-watchdog.sh – maintain default audio sink
BT_SINK="bluez_output.58_36_53_6F_FB_07.1"
FALLBACK_SINK="alsa_output.pci-0000_0f_00.6.analog-stereo"
CHECK_INTERVAL=1  # seconds

while true; do
	CURRENT=$(pactl get-default-sink)

	if pactl list short sinks | grep -q "$BT_SINK"; then
		pactl set-default-sink "$BT_SINK"
		echo "$(date '+%H:%M:%S') Active sink: $BT_SINK"

	elif pactl list short sinks | grep -q "$FALLBACK_SINK"; then
		pactl set-default-sink "$FALLBACK_SINK"
		echo "$(date '+%H:%M:%S') Active sink: $FALLBACK_SINK"

	else
		echo "$(date '+%H:%M:%S') DEBUG: No known sinks detected, current default: $CURRENT"
	fi

	sleep "$CHECK_INTERVAL"
done

