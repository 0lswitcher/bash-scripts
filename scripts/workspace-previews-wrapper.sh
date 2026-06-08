#!/usr/bin/env bash
# workspace-previews-wrapper.sh
# dependencies: workspace-previews-capture.sh, workspace-previews-popup.sh
# recursive dependencies: hyprland, hyprshot, feh

SH_DIR=/home/y2k/stuff/dev/bash/scripts

bash -l '"$SH_DIR"/workspace-previews-capture.sh' &
bash -l '"$SH_DIR"/workspace-previews-popup.sh' &