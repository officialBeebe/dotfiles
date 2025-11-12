#!/usr/bin/env bash
pactl list short sinks | awk '/bluez_output/ {print $1}' | while read -r idx; do
  pactl set-sink-mute "$idx" toggle
done

