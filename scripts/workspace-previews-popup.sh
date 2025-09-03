#!/usr/bin/env bash

# configuration
START_X_LEFT=20          # X position of the first icon on the LEFT monitor
START_X_RIGHT=1600+20    # X of the first icon on the RIGHT monitor
START_Y=0                # same vertical position for both monitors
ICON_WIDTH=33
ICON_HEIGHT=30
SPACING=2
NUM_WORKSPACES=5
IMAGE_DIR="$HOME/stuff/pictures/workspace-previews"
FEH_PID_FILE="/tmp/feh_workspace_preview.pid"

# state
last_workspace=""
last_x=""
last_y=""

function get_hovered_workspace() {
  local x=$1
  local y=$2

  for ((i = 0; i < NUM_WORKSPACES; i++)); do
    local left_l=$((START_X_LEFT + i * (ICON_WIDTH + SPACING)))
    local right_l=$((left_l + ICON_WIDTH))
    local left_r=$((START_X_RIGHT + i * (ICON_WIDTH + SPACING)))
    local right_r=$((left_r + ICON_WIDTH))
    local top=$START_Y
    local bottom=$((top + ICON_HEIGHT))

    # left monitor
    if (( x >= left_l && x <= right_l && y >= top && y <= bottom )); then
      echo $((i + 1))
      return
    fi

    # right monitor
    if (( x >= left_r && x <= right_r && y >= top && y <= bottom )); then
      echo $((i + 1))
      return
    fi
  done
}

function show_preview() {
  local workspace_id=$1
  local image_path="$IMAGE_DIR/${workspace_id}.png"

  # kill previous feh instance if running
  if [[ -f "$FEH_PID_FILE" ]]; then
    kill "$(cat "$FEH_PID_FILE")" 2>/dev/null
    rm -f "$FEH_PID_FILE"
  fi

  # show new preview if image exists
  if [[ -f "$image_path" ]]; then
    feh --title "preview_${workspace_id}" --geometry 400x225+20+45 --scale-down "$image_path" &
    echo $! > "$FEH_PID_FILE"
  fi
}

# main loop
while true; do
  read -r x y <<< "$(hyprctl cursorpos | awk '{print int($1), int($2)}')"

  # skip if mouse hasn't moved
  if [[ "$x" == "$last_x" && "$y" == "$last_y" ]]; then
    sleep 0.05
    continue
  fi

  hovered_workspace=$(get_hovered_workspace "$x" "$y")

  if [[ "$hovered_workspace" != "$last_workspace" ]]; then
    if [[ -n "$hovered_workspace" ]]; then
      show_preview "$hovered_workspace"
    else
      # hide preview if no longer hovering
      if [[ -f "$FEH_PID_FILE" ]]; then
        kill "$(cat "$FEH_PID_FILE")" 2>/dev/null
        rm -f "$FEH_PID_FILE"
      fi
    fi
    last_workspace="$hovered_workspace"
  fi

  last_x=$x
  last_y=$y
  sleep 0.05
done
