#!/bin/bash
# swww-as-theme.sh - convert wallpaper to theme
# NOTE: swww is deprectated in favor of awww,
#       this script will be removed soon.

if [ -f "$HOME/.cache/current-swww-img" ]; then
  theme=$(<"$HOME/.cache/current-swww-img")
  wal -i "$theme"
  bash /home/y2k/stuff/dev/bash/scripts/pywal-wrapper.sh
fi
