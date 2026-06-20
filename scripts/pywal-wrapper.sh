#!/usr/bin/env bash
# pywal-wrapper.sh - execute theme changes

if pgrep "waypaper" >/dev/null; then
  pkill waypaper

  # determine and define the selected wallpaper
  sed -i 's|~|/home/y2k|g' ~/.config/waypaper/config.ini
  SELECTED_WALLPAPER=$(grep -oP 'wallpaper\s*=\s*\K.*' ~/.config/waypaper/config.ini)
  echo "The selected wallpaper is: $SELECTED_WALLPAPER"

  # update cached file w/ current image dir
  echo "$SELECTED_WALLPAPER" >~/.cache/current-awww-img

  # generate the colorscheme from the selected wallpaper w/ pywal
  wal -i "$SELECTED_WALLPAPER" -n

  # pcmanfm-qt is not my default wallpaper manager,
  # but i use it for pcmanfm-qt --desktop mode for when
  # i have non-technical users on my machine
  if command -v pcmanfm-qt >/dev/null 2>&1; then
    pcmanfm-qt --set-wallpaper "$SELECTED_WALLPAPER"
  fi
fi

bash -l '/home/y2k/stuff/dev/bash/scripts/pywal-to-kando.sh' &
bash -il '/home/y2k/stuff/dev/bash/scripts/pywal-to-glance.sh' &
bash -il '/home/y2k/stuff/dev/bash/scripts/pywal-to-spicetify.sh' &

if pgrep "waybar" >/dev/null; then
  pkill -f waybar && setsid waybar >/dev/null 2>&1 &
  # notify-send "Waybar updated!" "Pywal colors applied to custom waybar theme :)"
  echo "Waybar updated!" "Pywal colors applied to custom waybar theme :)"
fi

if pgrep "firefox" >/dev/null; then
  pywalfox update
  # notify-send "Firefox updated!" "Pywal colors applied to custom firefox theme :)"
  echo "Firefox updated!" "Pywal colors applied to custom firefox theme :)"
fi

if pgrep "codium" >/dev/null; then
  # notify-send "VSCodium updated!" "Pywal colors applied to custom vscodium theme :)"
  echo "VSCodium updated!" "Pywal colors applied to custom vscodium theme :)"
fi

if pgrep "nvim" >/dev/null; then
  # notify-send "Neovim updated!" "Pywal colors applied to custom nvim theme :)"
  echo "Neovim updated!" "Pywal colors applied to custom nvim theme :)"
fi

if pgrep "pcmanfm-qt" >/dev/null; then
  pkill -f pcmanfm-qt && setsid pcmanfm-qt >/dev/null 2>&1 &
  # notify-send "File Explorer updated!" "Pywal colors applied to custom qt6ct -> pcmanfm-qt theme :)"
  echo "File Explorer updated!" "Pywal colors applied to custom qt6ct -> pcmanfm-qt theme :)"
fi

if pgrep "ulauncher" >/dev/null; then
  pkill -f ulauncher
  # notify-send "ulauncher updated!" "Pywal colors applied to custom ulauncher theme :)"
  echo "Ulauncher updated!" "Pywal colors applied to custom ulauncher theme :)"
fi

if pgrep -f "obsidian" >/dev/null; then
  xdg-open "obsidian://advanced-uri?vault=vault&commandid=obsidian-pywal-theme:reload-pywal-theme"
  # notify-send "Obsidian updated!" "Pywal colors applied to custom obsidian theme :)"
  echo "Obsidian updated!" "Pywal colors applied to custom obsidian theme :)"
fi

# clean exit since obsidian likes to throw non-fatal errors
exit 0
