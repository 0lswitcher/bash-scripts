#!/bin/bash

if [ -f "$HOME/.cache/current-swww-img" ]; then
    theme=$(<"$HOME/.cache/current-swww-img")
    wal -i "$theme"
    bash /home/y2k/stuff/dev/bash/scripts/pywal-to-spicetify.sh
fi
