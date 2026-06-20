#!/usr/bin/env bash
# pywal-to-glance.sh - convert pywal theme to glance dashboard theme
# dependencies: pywal, glance
# conditional dependencies: xdotool (only on x11 systems)

WAL_COLORS="$HOME/.cache/wal/colors.json"
GLANCE_CONFIG="/mnt/smith/docker/komodo/stacks-data/glance/configdir/glance.yml"
DASHBOARD_TITLE="NeoDash" # only needs to contain part of your title (ex. Huh?!-NeoDash -> NeoDash) 

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

# convert a hex color to HSL components (space-separated, no % signs)
hex_to_hsl() {
  local hex="${1#\#}" # strip leading # if present

  local r g b
  r=$((16#${hex:0:2}))
  g=$((16#${hex:2:2}))
  b=$((16#${hex:4:2}))

  # normalize to 0-1
  local rf gf bf
  rf=$(awk "BEGIN { printf \"%.6f\", $r / 255 }")
  gf=$(awk "BEGIN { printf \"%.6f\", $g / 255 }")
  bf=$(awk "BEGIN { printf \"%.6f\", $b / 255 }")

  awk -v r="$rf" -v g="$gf" -v b="$bf" '
    BEGIN {
        max = r > g ? r : g
        max = max > b ? max : b
        min = r < g ? r : g
        min = min < b ? min : b
        delta = max - min

        # lightness
        l = (max + min) / 2

        # saturation
        if (delta == 0) {
            s = 0
            h = 0
        } else {
            s = delta / (1 - (l > 0.5 ? 2*l - 1 : 2*l - 1 < 0 ? -(2*l - 1) : 2*l - 1))
            # fix: proper formula
            denom = 1 - (2 * l - 1 < 0 ? -(2 * l - 1) : (2 * l - 1))
            s = delta / denom

            if (max == r) {
                h = ((g - b) / delta) % 6
            } else if (max == g) {
                h = (b - r) / delta + 2
            } else {
                h = (r - g) / delta + 4
            }
            h = h * 60
            if (h < 0) h += 360
        }

        printf "%d %d %d", int(h + 0.5), int(s * 100 + 0.5), int(l * 100 + 0.5)
    }'
}

# extract hex colors from pywal (strip leading #)
background=$(jq -r '.special.background' "$WAL_COLORS")
foreground=$(jq -r '.special.foreground' "$WAL_COLORS")
color2=$(jq -r '.colors.color2' "$WAL_COLORS") # accent / primary
color1=$(jq -r '.colors.color1' "$WAL_COLORS") # negative (errors/red)
color3=$(jq -r '.colors.color3' "$WAL_COLORS") # positive (green-ish)

# convert to HSL
background_hsl=$(hex_to_hsl "$background")
primary_hsl=$(hex_to_hsl "$color2")
positive_hsl=$(hex_to_hsl "$color3")
negative_hsl=$(hex_to_hsl "$color1")

echo "Converted colors:"
echo "  background-color : $background_hsl  (from $background)"
echo "  primary-color    : $primary_hsl  (from $color2)"
echo "  positive-color   : $positive_hsl  (from $color3)"
echo "  negative-color   : $negative_hsl  (from $color1)"

# build the theme block to insert
THEME_BLOCK="theme:
  background-color: $background_hsl
  primary-color: $primary_hsl
  positive-color: $positive_hsl
  negative-color: $negative_hsl"

# remove any existing theme: block from the config
# (handles multi-line block by deleting from 'theme:' up to the next top-level key or EOF)
tmpfile=$(mktemp)

awk '
/^theme:/ { in_theme = 1; next }
in_theme && /^[a-zA-Z]/ { in_theme = 0 }
!in_theme { print }
' "$GLANCE_CONFIG" >"$tmpfile"

# prepend the new theme block at the top of the config
{
  echo "$THEME_BLOCK"
  echo ""
  cat "$tmpfile"
} >"$GLANCE_CONFIG"

rm -f "$tmpfile"

echo "Glance updated!"
#notify-send "Glance updated!" "Pywal colors applied to your Glance dashboard :)"
echo "Attempting browser window refresh..."

# refresh the firefox window with glance dashboard if it's open
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
  echo "Hyprland detected..."
  sleep 0.77 &&
    hyprctl dispatch 'hl.dsp.focus({ window = "title:^(.*'"$DASHBOARD_TITLE"'.*)$"})'
    hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "CTRL", key = "r", window = "title:^(.*'"$DASHBOARD_TITLE"'.*)$"})'
  echo "Browser window refreshed!"
elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  echo "Wayland detected..."
  echo ""
  echo "ERROR: Configuration required!"
  echo ""
  echo "You've got yourself an edgecase!"
  echo "I designed this script to run on Hyprland by default, and to fallback to xdotool for x11 based WM's."
  echo "You can still use the script, but you'll have to manually configure it with a window refresh method specific to your"
  echo "WM if you want your browser to auto refresh when you run the script."
  echo ""
  echo "After doing so, please submit a PR so I can add it to the main branch for everyone to use! :)"
elif command -v xdotool &>/dev/null; then
  echo "xdotool detected..."
  # save the id of the active window when script is ran for returning focus later
  ORIGINAL_WINDOW=$(xdotool getactivewindow 2>/dev/null)

  # regex list of common browser window classes
  BROWSER_REGEX="(?i)(firefox|chrome|chromium|brave|opera|vivaldi|zen)"

  # find all window ids on the x server
  ALL_WINDOWS=$(xdotool search --onlyvisible --class ".*" 2>/dev/null)
  TARGET_WINDOW_ID=""

  # loop through open windows to find the first matching browser
  for win_id in $ALL_WINDOWS; do
    # fetch the actual class name of the window
    WIN_CLASS=$(xdotool getwindowclassname "$win_id" 2>/dev/null)
    WIN_TITLE=$(xdotool getwindowname "$win_id" 2>/dev/null)
    if echo "$WIN_CLASS" | grep -Pq "$BROWSER_REGEX"; then
      if echo "$WIN_TITLE" | grep -Fqi "$DASHBOARD_TITLE"; then
        TARGET_WINDOW_ID="$win_id"
        break
      fi
    fi
  done

  # execute the refresh sequence if a browser is found
  if [ -n "$TARGET_WINDOW_ID" ]; then
    # focus the browser window and refresh it w/ simulated keypress
    xdotool windowactivate "$TARGET_WINDOW_ID"
    sleep 0.1 # buffer
    xdotool key "ctrl+r"

    # restore focus back to the original window
    if [ -n "$ORIGINAL_WINDOW" ] && [ "$ORIGINAL_WINDOW" -ne 0 ]; then
      sleep 0.1 # buffer
      xdotool windowactivate "$ORIGINAL_WINDOW"
    fi
  else
    echo "ERROR: No active web browser detected."
    exit 1
  fi
else
  echo "ERROR: xdotool is required for full script functionality with x11-based WM's. Please install it, then run this script again."
  echo "       Until you do so, your colors will update-but you must manually refresh your browser."
  exit 1
fi