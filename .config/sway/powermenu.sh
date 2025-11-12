#!/usr/bin/env bash
#
# wofi-based system power menu for Wayland (sway/wlroots)
# Supports: Shutdown, Reboot, Suspend, Hibernate, Lock, Logout
#
# Author: Adapted from Benjamin Chrétien & joekamprad
# License: GPLv3

# ----------------- CONFIG ----------------- #

# Lock command (replace with swaylock or custom script)
LOCKSCRIPT="swaylock -f"

# Colors handled via wofi CSS theme instead of CLI options

# Enable confirmation for destructive actions
enable_confirmation=false

# ----------------- MENU ----------------- #

declare -A menu=(
    ["Shutdown"]="systemctl poweroff"
    ["Reboot"]="systemctl reboot"
    ["Suspend"]="systemctl suspend"
    ["Hibernate"]="systemctl hibernate"
    ["Lock"]="$LOCKSCRIPT"
    ["Logout"]="swaymsg exit"
    ["Cancel"]=""
)

# Items that need confirmation
menu_confirm=("Shutdown" "Reboot" "Suspend" "Hibernate" "Logout")

# ----------------- FUNCTIONS ----------------- #

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Ask confirmation via wofi
ask_confirmation() {
    local choice="$1"
    local response
    response=$(printf "Yes\nNo" | wofi --dmenu --prompt="Are you sure you want to $choice?")
    [[ "$response" == "Yes" ]]
}

# ----------------- ARG PARSING ----------------- #

while getopts "c" opt; do
    case "$opt" in
        c) enable_confirmation=true ;;
        *) echo "Usage: $0 [-c]"; exit 1 ;;
    esac
done

# ----------------- MAIN ----------------- #

# Ensure wofi exists
if ! command_exists wofi; then
    echo "wofi not found!"
    exit 1
fi

# Show menu via wofi
selection=$(printf '%s\n' "${!menu[@]}" | sort | wofi --dmenu --prompt="Power Menu:")

# Exit if cancelled or empty
[[ -z "$selection" || "$selection" == "Cancel" ]] && exit 0

# Confirmation check
if $enable_confirmation && [[ " ${menu_confirm[*]} " =~ " $selection " ]]; then
    ask_confirmation "$selection" || exit 0
fi

# Execute the selected command
eval "${menu[$selection]}"

