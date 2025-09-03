#!/usr/bin/env bash

THEME_DIR="$HOME/stuff/themes"
PREVIEW_IMG="$HOME/.cache/fzf_theme_preview.png"
DEBOUNCE_FILE="/tmp/fzf_theme_debounce"

# Gather themes (.sh files) and sort them alphabetically
mapfile -t THEMES < <(find "$THEME_DIR" -maxdepth 1 -type f -name '*.sh' -printf '%f\n' | sort)

cleanup() {
    pkill -f "feh --title fzf-theme-preview" 2>/dev/null
    rm -f "$PREVIEW_IMG"
    rm -f "$DEBOUNCE_FILE"
}
trap cleanup EXIT

[ ${#THEMES[@]} -eq 0 ] && {
    echo "No themes found in $THEME_DIR"
    exit 1
}

# Initialize preview with first theme
basename="${THEMES[0]%.sh}"
ln -sf "$THEME_DIR/$basename.png" "$PREVIEW_IMG"

feh --title fzf-theme-preview --geometry 645x589+600+250 --scale-down --image-bg black --reload 1 --no-menus "$PREVIEW_IMG" &
FEH_PID=$!

preview_cmd() {
    local scriptname="$1"
    local base="${scriptname%.sh}"
    local imgpath="$THEME_DIR/$base.png"

    [ ! -f "$imgpath" ] && return

    local now=$(date +%s%3N)
    if [ -f "$DEBOUNCE_FILE" ]; then
        local last_update
        last_update=$(cat "$DEBOUNCE_FILE")
        local diff=$((now - last_update))
        if (( diff < 200 )); then
            return
        fi
    fi

    ln -sf "$imgpath" "$PREVIEW_IMG"
    echo "$now" > "$DEBOUNCE_FILE"
}

export -f preview_cmd
export THEME_DIR
export PREVIEW_IMG
export DEBOUNCE_FILE

selected=$(printf '%s\n' "${THEMES[@]}" | fzf \
    --height=100% --border --prompt=" Choose theme: " \
    --preview "bash -c 'preview_cmd {}'" \
    --preview-window=right:0%:wrap \
    --bind "enter:accept" \
    --cycle)

if [ -n "$selected" ]; then
    CURRENT_THEME=$(<"$THEME_DIR/$selected")
    bash "$THEME_DIR/$selected"
    bash "$HOME/stuff/coding/bash/scripts/pywal-to-spicetify.sh"
    echo "$CURRENT_THEME" > /home/y2k/.cache/current-pywal-theme
fi

cleanup

