#!/usr/bin/env bash
# awww-as-theme.sh - convert wallpaper to theme

if [ -f "$HOME/.cache/current-awww-img" ]; then
  theme=$(<"$HOME/.cache/current-awww-img")
  wal -i "$theme" -n
  bash /home/y2k/stuff/dev/bash/scripts/pywal-wrapper.sh
fi
