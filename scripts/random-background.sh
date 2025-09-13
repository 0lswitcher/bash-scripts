#!/usr/bin/env bash
# random-background.sh - set a random wallpaper using swww

set -euo pipefail

BACKGROUND_DIR="${1:-$HOME/stuff/pictures/backgrounds}"

if [[ ! -d "$BACKGROUND_DIR" ]]; then
    notify-send "Random Background" "Directory not found: $BACKGROUND_DIR"
    exit 1
fi

# pick a random file
background=$(find "$BACKGROUND_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' \) | shuf -n 1)

if [[ -z "$background" ]]; then
    notify-send "Random Background" "No images found in $BACKGROUND_DIR"
    exit 1
fi

swww img "$background" --transition-type random
notify-send "Random Wallpaper" "Set: $(basename "$background")"
