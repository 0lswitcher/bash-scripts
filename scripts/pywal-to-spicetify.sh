#!/usr/bin/env bash
# pywal-to-spicetify.sh - convert pywal theme to spicetify theme
# dependencies: pywal, spotify, spicetify, jq

WAL_COLORS="$HOME/.cache/wal/colors.json"
COLOR_INI="$HOME/.config/spicetify/Themes/text/color.ini"
SECTION="[Pywal]"

# func to check if using flatpak install
check_for_flatpak() {
  FLATPAK_APPID="com.spotify.Client"
  flatpak info "$FLATPAK_APPID" >/dev/null 2>&1
}

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
accent=$(jq -r '.colors.color2' "$WAL_COLORS" | sed 's/#//')
main=$(jq -r '.special.background' "$WAL_COLORS" | sed 's/#//')
text=$(jq -r '.special.foreground' "$WAL_COLORS" | sed 's/#//')
subtext=$(jq -r '.colors.color7' "$WAL_COLORS" | sed 's/#//')
notification=$(jq -r '.colors.color4' "$WAL_COLORS" | sed 's/#//')
notification_error=$(jq -r '.colors.color1' "$WAL_COLORS" | sed 's/#//')
highlight=$(jq -r '.colors.color8' "$WAL_COLORS" | sed 's/#//')
header=$(jq -r '.colors.color0' "$WAL_COLORS" | sed 's/#//')
border=$(jq -r '.colors.color3' "$WAL_COLORS" | sed 's/#//')

# generate the [Pywal] section
cat <<EOF >/tmp/pywal_spicetify.ini
$SECTION
accent             = ${accent}
accent-active      = ${accent}
accent-inactive    = ${main}
banner             = ${accent}
border-active      = ${accent}
border-inactive    = ${border}
header             = ${header}
highlight          = ${highlight}
main               = ${main}
notification       = ${notification}
notification-error = ${notification_error}
subtext            = ${subtext}
text               = ${text}
EOF

# remove existing [Pywal] section if it exists
sed -i '/^\[Pywal\]/,/^\[.*\]/d' "$COLOR_INI"

# append new [Pywal] section
cat /tmp/pywal_spicetify.ini >>"$COLOR_INI"

# set the color scheme (deprecated in favor of live refresh, still here if u need it)
#spicetify config color_scheme Pywal

# reloads color.ini and user.css
spicetify refresh

# apply it (deprecated in favor of live refresh, still here if u need it)
#spicetify apply

# checks if spotify is open, if not-cya!
if ! pgrep "spotify" >/dev/null; then
  echo "Spotify updated!"
  #notify-send "Spotify updated!" "Pywal colors applied to custom spicetify theme :)"
  exit 0
fi

# if spotify is open, check for version and refresh accordingly

# check for hyprland (refresh)
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
  hyprctl dispatch 'hl.dsp.focus({ window = "class:^(.*Spotify.*)$"})' &&
  hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "CTRL+SHIFT", key = "r", window = "class:^(.*Spotify.*)$"})' 
  exit 0
fi

# check for flatpak (close n re-open)
if check_for_flatpak; then
  flatpak kill com.spotify.Client 2>/dev/null &&
  # delete old spotify singletons jik
  find "$HOME/.var/app/com.spotify.Client/cache/spotify/" -name 'Singleton*' -delete 2>/dev/null
  setsid flatpak run com.spotify.Client >/dev/null 2>&1 &
else # assume native installation (close n re-open)
  pkill -f spotify 2>/dev/null
  setsid spotify >/dev/null 2>&1 &
fi

echo "Spotify updated!"

#notify-send "Spotify updated!" "Pywal colors applied to custom spicetify theme :)"
