#!/usr/bin/env bash
# random-background.sh - set a random wallpaper using awww

set -euo pipefail

BACKGROUND_DIR="${1:-$HOME/stuff/pictures/wallpapers/all}"

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

# set the background w/ awww (swww has been deprecated)
awww img "$background" --transition-type random

# check if notify-send exists before running it
if command -v notify-send >/dev/null 2>&1; then
  notify-send "Random Wallpaper" "Set: $(basename "$background")"
else
  echo "Random wallpaper set to $background"
fi

# updated cached file w/ current image dir
echo "$background" >~/.cache/current-awww-img

# pcmanfm-qt is not my default wallpaper manager,
# but i use it for pcmanfm-qt --desktop mode for when
# i have non-technical users on my machine
if command -v pcmanfm-qt >/dev/null 2>&1; then
  pcmanfm-qt --set-wallpaper "$background"
fi
