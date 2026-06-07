#!/usr/bin/env bash
# pywal-to-kando.sh - convert pywal theme to kando theme
# dependencies:  pywal, kando, jq

# note: to use this script without the flatpak version of kando,
#       comment out line 14 and uncomment line 11.
#       also see end of script for reloading kando's theme.

WAL_COLORS="$HOME/.cache/wal/colors.json"

# version for native install
CONFIG_FILE="$HOME/.config/kando/config.json"

# version for flatpak install
# CONFIG_FILE="$HOME/.var/app/menu.kando.Kando/config/kando/config.json"

# check if the colors.json file exists
if [ ! -f "$WAL_COLORS" ]; then
  echo "Cached Pywal colors.json file not found at $WAL_COLORS"
  exit 1
fi

# check if jq is installed
if ! command -v jq &>/dev/null; then
  echo "Error: 'jq' is required but not installed."
  echo "Please install it through your package manager to use this script."
  exit 1
fi

# extract colors from pywal using jq
bg=$(jq -r '.special.background' "$WAL_COLORS")
fg=$(jq -r '.special.foreground' "$WAL_COLORS")
c1=$(jq -r '.colors.color1' "$WAL_COLORS")
c2=$(jq -r '.colors.color2' "$WAL_COLORS")
c3=$(jq -r '.colors.color3' "$WAL_COLORS")
c4=$(jq -r '.colors.color4' "$WAL_COLORS")
c5=$(jq -r '.colors.color5' "$WAL_COLORS")
c7=$(jq -r '.colors.color7' "$WAL_COLORS")

# patch only the menuThemeColors key, leaving the rest of config.json untouched
jq --arg c1 "$c1" --arg c2 "$c2" --arg c3 "$c3" --arg c4 "$c4" \
  --arg c5 "$c5" --arg c7 "$c7" --arg bg "$bg" --arg fg "$fg" \
  '.menuThemeColors["nether-labels"] = {
    "accent-color": $c1,
    "hover-color": $c2,
    "submenu-items-hover-color": $c3,
    "text-hover-color": $c4,
    "connector-color": $c1,
    "shrinked-outline-color": $c5,
    "circle-color": $bg,
    "border-color": $c7,
    "submenu-items-color": $fg,
    "label-background-color": $bg,
    "text-color": $fg
  }' "$CONFIG_FILE" >/tmp/kando-config.json && mv /tmp/kando-config.json "$CONFIG_FILE"

# kill and reopen kando instance
kando --reload-menu-theme
#sleep 2s && setsid kando >/dev/null 2>&1 &
#flatpak kill menu.kando.Kando && setsid flatpak run menu.kando.Kando >/dev/null 2>&1 &
echo "Kando updated!"
#notify-send "Kando updated!" "Pywal colors applied to custom kando theme :)"
