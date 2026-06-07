#!/usr/bin/env bash
# pywal-to-spicetify.sh - convert pywal theme to spicetify theme
# dependencies: pywal, spotify, spicetify, jq

# note: to use this script without the flatpak version of spotify,
#       edit the final block to reference the non-flatpak variants.

WAL_COLORS="$HOME/.cache/wal/colors.json"
COLOR_INI="$HOME/.config/spicetify/Themes/text/color.ini"
SECTION="[Pywal]"

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

# set the color scheme
spicetify config color_scheme Pywal

# apply it
spicetify apply

# change me if using non-flatpak installation!
if pgrep "spotify" >/dev/null; then
  # close spotify instance if one is open
  flatpak kill com.spotify.Client
  # delete old spotify singletons jik
  find "$HOME/.var/app/com.spotify.Client/cache/spotify/" -name 'Singleton*' -delete

  # open spotify
  setsid flatpak run com.spotify.Client >/dev/null 2>&1 &
  echo "Spotify updated!"
  #notify-send "Spotify updated!" "Pywal colors applied to custom spicetify theme :)"
fi
