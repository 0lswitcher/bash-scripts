#!/usr/bin/env bash
# colorscheme-picker.sh - colorscheme selection and application w/ fzf and image previews
# USAGE: foot/kitty/alacritty -T ColorschemePicker bash ~/path/to/colorscheme-picker.sh

THEMES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../themes" && pwd -P)"
PREVIEW_IMG="$HOME/.cache/fzf_theme_preview.png"
DEBOUNCE_FILE="/tmp/fzf_theme_debounce"

# gather themes (.sh files) and sort them alphabetically
mapfile -t THEMES < <(find "$THEMES_DIR" -maxdepth 1 -type f -name '*.sh' -printf '%f\n' | sort)

cleanup() {
  pkill -f "feh --title ThemePreview" 2>/dev/null
  rm -f "$PREVIEW_IMG"
  rm -f "$DEBOUNCE_FILE"
}
trap cleanup EXIT

[ ${#THEMES[@]} -eq 0 ] && {
  echo "No themes found in $THEMES_DIR"
  exit 1
}

# initialize preview with first theme
basename="${THEMES[0]%.sh}"
ln -sf "$THEMES_DIR/$basename.png" "$PREVIEW_IMG"

feh --title ColorschemePreview --geometry 645x589+600+250 --scale-down --image-bg black --reload 1 --no-menus "$PREVIEW_IMG" &
FEH_PID=$!

preview_cmd() {
  local scriptname="$1"
  local base="${scriptname%.sh}"
  local imgpath="$THEMES_DIR/$base.png"

  [ ! -f "$imgpath" ] && return

  # debounce logic: only update if 200ms have passed since last update
  local now=$(date +%s%3N) # current time in milliseconds
  if [ -f "$DEBOUNCE_FILE" ]; then
    local last_update
    last_update=$(cat "$DEBOUNCE_FILE")
    local diff=$((now - last_update))
    if ((diff < 200)); then
      # too soon, skip updating preview
      return
    fi
  fi

  # update symlink to new image for feh preview
  ln -sf "$imgpath" "$PREVIEW_IMG"

  # record timestamp of this update
  echo "$now" >"$DEBOUNCE_FILE"
}

export -f preview_cmd
export THEMES_DIR
export PREVIEW_IMG
export DEBOUNCE_FILE

selected=$(printf '%s\n' "${THEMES[@]}" | fzf \
  --height=100% --border --prompt=" Choose theme: " \
  --layout=reverse \
  --ansi \
  --preview "bash -c 'preview_cmd {}'" \
  --preview-window=right:0%:wrap \
  --bind "enter:accept" \
  --cycle)

# update current theme and run pywal-wrapper.sh
if [ -n "$selected" ]; then
  CURRENT_THEME=$(<"$THEMES_DIR/$selected")
  bash "$THEMES_DIR/$selected"
  bash "$HOME/stuff/dev/bash/scripts/pywal-wrapper.sh"
fi

cleanup
