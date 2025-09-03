#!/usr/bin/env bash
# swww-as-theme.sh - convert current background / wallpaper to pywal theme

if [ -f "$HOME/.cache/current-swww-img" ]; then
    theme=$(<"$HOME/.cache/current-swww-img")
    wal -i "$theme"
    echo "$theme" > ~/.cache/current-pywal-theme
    bash /home/y2k/stuff/coding/bash/scripts/pywal-to-spicetify.sh
fi
