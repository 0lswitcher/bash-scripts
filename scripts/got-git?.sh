#!/usr/bin/env bash
# got-git?.sh - check which dirs are git repos and show their status

BASE_DIR="$HOME/stuff/dev/git"

# ANSI colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${BOLD}Scanning $BASE_DIR...${RESET}"
echo

for dir in "$BASE_DIR"/*; do
  if [ -d "$dir" ]; then
    cd "$dir" || continue

    if [ -d ".git" ]; then
      echo -e "${CYAN} $(basename "$dir")${RESET} ${GREEN}[git repo]${RESET}"

      branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
      status=$(git status -s)

      echo -e "     Branch: ${BOLD}$branch${RESET}"

      if [ -z "$status" ]; then
        echo -e "   ${GREEN} Clean (no changes)${RESET}"
      else
        echo -e "   ${YELLOW} Uncommitted changes:${RESET}"
        echo "$status" | sed "s/^/      /"
      fi

      git fetch --quiet 2>/dev/null
      ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
      behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)

      if [ "$ahead" -gt 0 ]; then
        echo -e "   ${BLUE}↑ $ahead commits ahead of remote${RESET}"
      fi
      if [ "$behind" -gt 0 ]; then
        echo -e "   ${RED}↓ $behind commits behind remote${RESET}"
      fi
      if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
        echo -e "   ${GREEN} Up to date with remote${RESET}"
      fi
      echo
    else
      echo -e "${CYAN} $(basename "$dir")${RESET} ${RED}[not a git repo]${RESET}"
      echo
    fi
  fi
done
