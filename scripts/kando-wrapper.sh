#!/usr/bin/env bash
# kando-wrapper.sh - fix hyprland being unable to launch kando on boot

if ! pgrep -f "electron" >/dev/null; then
  kando >/dev/null 2>&1 &
  sleep 2 &&
    notify-send "kando-wrapper.sh" "First open is slow, sorry! :( \nSubsequent boots will be much faster :) \nIf Kando doesn't launch, \nplease press the bind again." &&
    hyprctl dispatch 'hl.dsp.global("menu.kando.Kando:sao")'
fi

hyprctl dispatch 'hl.dsp.global("menu.kando.Kando:sao")'
