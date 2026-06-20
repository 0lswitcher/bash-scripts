#!/usr/bin/env bash
# nix-bootstrap.sh - run post NixOS installation

set -euo pipefail

# dev / dry-run flag parsing
# pass --0lswitcher to enable dev mode
# pass --dry-run to simulate all destructive commands without executing them
DEV_MODE=0
DRY_RUN=0
for arg in "$@"; do
  [[ "$arg" == "--0lswitcher" ]] && DEV_MODE=1
  [[ "$arg" == "--dry-run" ]] && DRY_RUN=1
done

# run() wrapper
# wraps any destructive command so dry-run mode prints instead of executing
# non-destructive commands (git clone, grep, read, echo) are called normally
run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

# logging
LOG_FILE="/tmp/nix-bootstrap.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "--- nix-bootstrap started at $(date) ---"
[[ $DEV_MODE -eq 1 ]] && echo "[dev mode active]"
[[ $DRY_RUN -eq 1 ]] && echo "[dry-run mode active - no destructive commands will execute]"

# trap - fires on any non-zero exit, prints the line number and points to the log
trap 'echo ""; echo "Bootstrap failed at line $LINENO. Check $LOG_FILE for details."' ERR

# self-bootstrap - ensure git is available
if ! command -v git &>/dev/null || ! command -v stow &>/dev/null; then
  echo "[git/stow] not found - launching via nix-shell..."
  exec nix-shell -p git stow --run "bash $(realpath "$0") $(printf '%q ' "$@")"
fi

# vars
REPO_DIR="/tmp/nix-bootstrap"
NIXOS_DIR="/etc/nixos"
DOTFILES_REPO="https://github.com/0lswitcher/dotfiles.git"
DOTFILES_PRIVATE_REPO="https://github.com/0lswitcher/dotfiles-private.git"
NIXFILES_REPO="https://github.com/0lswitcher/nixfiles.git"
WALLPAPERS_REPO="https://github.com/0lswitcher/wallpapers.git"

# functions
prompt() {
  local message="$1"
  shift
  local options=("$@")
  local choice

  echo "$message" >&2
  select choice in "${options[@]}"; do
    if [[ -n "$choice" ]]; then
      echo "$choice"
      return 0
    else
      echo "Invalid choice. Please try again." >&2
    fi
  done
}

clone_or_update_repo() {
  local repo_url="$1"
  local target_dir="$2"

  if [ -d "$target_dir/.git" ]; then
    echo "Updating $target_dir..."
    git -C "$target_dir" pull --ff-only
  else
    echo "Cloning $repo_url..."
    git clone "$repo_url" "$target_dir"
  fi
}

# welcome art
cat <<"EOF"

                           
       ▓▓▓    ▒▒▒  ▒▒▒      
        ▓▓▓    ▒▒▒▒▒▒       
     ▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒          ██████   █████  ███  
    ▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒  ▓▓▓    ░░██████ ░░███  ░░░  
        ▒▒▒       ▒▒▒▓▓▓      ░███░███ ░███  ████  █████ █████    
  ▒▒▒▒▒▒▒▒         ▒▓▓▓▓▓▓▓   ░███░░███░███ ░░███ ░░███ ░░███  
  ▒▒▒▒▒▒▒▓         ▓▓▓▓▓▓▓▓   ░███ ░░██████  ░███  ░░░█████░    
     ▒▒▒▓▓▓       ▓▓▓         ░███  ░░█████  ░███   ███░░░███    
    ▒▒▒  ▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒     █████  ░░█████ █████ █████ █████  
         ▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒     ░░░░░    ░░░░░ ░░░░░ ░░░░░ ░░░░░   
        ▓▓▓▓▓▓    ▒▒▒       
       ▓▓▓  ▓▓▓    ▒▒▒      
                                                                                                                    
                                                                                         
  ███████████                     █████             █████                                 
 ░░███░░░░░███                   ░░███             ░░███                                  
  ░███    ░███  ██████   ██████  ███████    █████  ███████   ████████   ██████   ████████ 
  ░██████████  ███░░███ ███░░███░░░███░    ███░░  ░░░███░   ░░███░░███ ░░░░░███ ░░███░░███
  ░███░░░░░███░███ ░███░███ ░███  ░███    ░░█████   ░███     ░███ ░░░   ███████  ░███ ░███
  ░███    ░███░███ ░███░███ ░███  ░███ ███ ░░░░███  ░███ ███ ░███      ███░░███  ░███ ░███
  ███████████ ░░██████ ░░██████   ░░█████  ██████   ░░█████  █████    ░░████████ ░███████ 
 ░░░░░░░░░░░   ░░░░░░   ░░░░░░     ░░░░░  ░░░░░░     ░░░░░  ░░░░░      ░░░░░░░░  ░███░░░  
                                                                                ░███     
                                                                                █████    
                                                                               ░░░░░     
                                                                               
EOF

# online / offline prompt
if ping -c 1 github.com &>/dev/null; then
  MODE=$(prompt "Choose installation mode:" "Online" "Offline")
else
  echo "No internet connection detected. Defaulting to Offline mode."
  MODE="Offline"
fi

echo "Selected mode: $MODE"

if [ "$MODE" = "Online" ]; then
  echo "Running in Online mode - cloning repositories..."
  clone_or_update_repo "$DOTFILES_REPO" "$REPO_DIR/dotfiles"
  clone_or_update_repo "$NIXFILES_REPO" "$REPO_DIR/nixfiles"
  if [[ $DEV_MODE -eq 1 ]]; then
    echo "[dev] Pulling private dotfiles..."
    clone_or_update_repo "$DOTFILES_PRIVATE_REPO" "$REPO_DIR/dotfiles-private"
  fi
else
  echo "Running in Offline mode..."
  read -rp "Enter the path where offline repos are located: " OFFLINE_PATH
  REPO_DIR="$OFFLINE_PATH"
  read -rp "Enter the path to your dotfiles repo (default: /home/$TARGET_USER/dotfiles): " DOTFILES_OVERRIDE
  DOTFILES_DIR_FINAL="${DOTFILES_OVERRIDE:-/home/$TARGET_USER/dotfiles}"
fi

# install type prompt
INSTALL_TYPE=$(prompt "Select installation type:" "Server" "Minimal" "Full")
echo "Selected installation type: $INSTALL_TYPE"

# hardware type prompt
HW_TYPE=$(prompt "Select hardware:" "Desktop" "Laptop")
echo "Selected hardware type: $HW_TYPE"

# validate role file exists before proceeding
ROLE_FILE="$REPO_DIR/nixfiles/roles/${INSTALL_TYPE,,}.nix"
if [[ ! -f "$ROLE_FILE" ]]; then
  echo "Error: role file not found: $ROLE_FILE"
  echo "Check that nixfiles/roles/${INSTALL_TYPE,,}.nix exists in your nixfiles repo."
  exit 1
fi

# username prompt
read -rp "Enter the username for your new user (this will replace 'changeme' in base.nix): " TARGET_USER
if [[ -z "$TARGET_USER" ]]; then
  echo "Error: Username cannot be empty"
  exit 1
fi
echo "Selected username: $TARGET_USER"

# define final dotfiles location (set to $HOME so GNU Stow can be used)
DOTFILES_DIR_FINAL="/home/$TARGET_USER/dotfiles"
DOTFILES_PRIVATE_DIR_FINAL="/home/$TARGET_USER/dotfiles-private" # (dev mode only)

# hostname prompt
read -rp "Enter the new hostname for your machine (not to be confused w/ username): " TARGET_HOST
if [[ -z "$TARGET_HOST" ]]; then
  echo "Error: Hostname cannot be empty"
  exit 1
fi
echo "Selected hostname: $TARGET_HOST"

# wallpaper prompt (skipped in dev mode)
if [[ $DEV_MODE -eq 1 ]]; then
  echo "[dev] Skipping wallpaper prompt - Pulling automatically..."
  BG_PULL="Hell yeah"
else
  BG_PULL=$(prompt "Would you like to include my wallpaper collection in your final build?" "Hell yeah" "Fuck no")
fi

if [ "$BG_PULL" = "Hell yeah" ]; then
  echo "Sweet, pulling wallpapers from repository now..."
  clone_or_update_repo "$WALLPAPERS_REPO" "/home/$TARGET_USER/stuff/pictures/backgrounds"
else
  echo "No worries, skipping wallpapers and moving on to dotfiles."
fi

# backup existing /etc/nixos before touching it
BACKUP_PATH="/etc/nixos.bak.$(date +%Y%m%d%H%M%S)"
echo "Backing up $NIXOS_DIR to $BACKUP_PATH..."
run sudo cp -r "$NIXOS_DIR" "$BACKUP_PATH"

# extract stateVersion from existing configuration.nix
echo "Extracting system.stateVersion from existing configuration..."
NIXOS_VER=$(grep -oP '"\K[0-9]+\.[0-9]+(?=")' "$NIXOS_DIR/configuration.nix" 2>/dev/null || true)

# write configuration.nix
echo "Generating configuration.nix with imports..."
run sudo cp "$REPO_DIR/nixfiles/base.nix" "$NIXOS_DIR/base.nix"
run sudo cp "$ROLE_FILE" "$NIXOS_DIR/role.nix"

echo "Updating username in base.nix from 'changeme' to '$TARGET_USER'..."
run sudo sed -i "s/changeme/$TARGET_USER/g" "$NIXOS_DIR/base.nix"

echo "Updating hostname in base.nix from 'CHANGEME' to '$TARGET_HOST'..."
run sudo sed -i "s/CHANGEME/$TARGET_HOST/g" "$NIXOS_DIR/base.nix"

if [[ -n "$NIXOS_VER" ]]; then
  echo "Adding system.stateVersion: $NIXOS_VER"
  if [[ $DRY_RUN -eq 0 ]]; then
    sudo tee "$NIXOS_DIR/configuration.nix" >/dev/null <<EOF
{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
    ./role.nix
    ./hardware-configuration.nix
  ];

  system.stateVersion = "$NIXOS_VER";
}
EOF
  else
    echo "[dry-run] sudo tee $NIXOS_DIR/configuration.nix (would write with stateVersion = \"$NIXOS_VER\")"
  fi
else
  echo "Warning: Could not find system.stateVersion in original configuration.nix"
  echo "You may need to add it manually or run nixos-generate-config first"
  if [[ $DRY_RUN -eq 0 ]]; then
    sudo tee "$NIXOS_DIR/configuration.nix" >/dev/null <<'EOF'
{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
    ./role.nix
    ./hardware-configuration.nix
  ];

  # WARNING: system.stateVersion could not be detected - add it manually!
}
EOF
  else
    echo "[dry-run] sudo tee $NIXOS_DIR/configuration.nix (would write without stateVersion - manual addition required)"
  fi
fi

# apply dotfiles
echo "Applying dotfiles for $HW_TYPE to future user $TARGET_USER..."
TARGET_USER_HOME="/home/$TARGET_USER"

# transfer dots from pre-rebuild to post-rebuild dir
echo "Checking $TARGET_USER_HOME/.config dir exists..."
run sudo mkdir -p "$TARGET_USER_HOME/.config"
echo "Checking $TARGET_USER_HOME/dotfiles dir exists..."
run sudo mkdir -p "$TARGET_USER_HOME/dotfiles"
echo "Copying dots from $REPO_DIR/dotfiles to $DOTFILES_DIR_FINAL..."
run sudo cp -r "$REPO_DIR/dotfiles" "$DOTFILES_DIR_FINAL"

# full list of stow packages
STOW_PACKAGES=(btop cava fastfetch foot hypr kando laptop-specific micro nvim ranger spicetify theming ulauncher waybar)

# laptop: swap desktop waybar for laptop-specific (battery, brightness, etc.)
if [ "$HW_TYPE" = "Laptop" ]; then
  STOW_PACKAGES=("${STOW_PACKAGES[@]/waybar/}")
  STOW_PACKAGES+=("laptop-specific")
fi

# server: strip all GUI-related and unneeded packages
if [ "$INSTALL_TYPE" = "Server" ]; then
  STOW_PACKAGES=("${STOW_PACKAGES[@]/cava/}")
  STOW_PACKAGES=("${STOW_PACKAGES[@]/fastfetch/}")
  STOW_PACKAGES=("${STOW_PACKAGES[@]/foot/}")
  STOW_PACKAGES=("${STOW_PACKAGES[@]/hypr/}")
  STOW_PACKAGES=("${STOW_PACKAGES[@]/kando/}")
  STOW_PACKAGES=("${STOW_PACKAGES[@]/laptop-specific/}")
  STOW_PACKAGES=("${STOW_PACKAGES[@]/nvim/}")
  STOW_PACKAGES=("${STOW_PACKAGES[@]/spicetify/}")
  STOW_PACKAGES=("${STOW_PACKAGES[@]/theming/}")
  STOW_PACKAGES=("${STOW_PACKAGES[@]/ulauncher/}")
  STOW_PACKAGES=("${STOW_PACKAGES[@]/waybar/}")
fi

for pkg in "${STOW_PACKAGES[@]}"; do
  # pattern substitution leaves empty strings for removed entries - skip em
  [[ -z "$pkg" ]] && continue
  echo "Stowing $pkg..."
  run sudo stow -d "$DOTFILES_DIR_FINAL" -t "$TARGET_USER_HOME" "$pkg"
done

# apply private dotfiles via stow (dev mode only)
if [[ $DEV_MODE -eq 1 && -d "$REPO_DIR/dotfiles-private" ]]; then
  echo "[dev] Stowing private dotfiles..."
  echo "Checking $TARGET_USER_HOME/dotfiles-private dir exists..."
  run sudo mkdir -p "$TARGET_USER_HOME/dotfiles-private"
  echo "Copying dots from $REPO_DIR/dotfiles-private to $DOTFILES_PRIVATE_DIR_FINAL..."
  run sudo cp -r "$REPO_DIR/dotfiles-private" "$DOTFILES_PRIVATE_DIR_FINAL"

  # stow each package found in dotfiles-private
  for pkg in "$DOTFILES_PRIVATE_DIR_FINAL"/*/; do
    pkg=$(basename "$pkg")
    echo "[dev] Stowing private package: $pkg..."
    run sudo stow -d "$DOTFILES_PRIVATE_DIR_FINAL" -t "$TARGET_USER_HOME" "$pkg"
  done
fi

echo "Dotfiles successfully stowed to $TARGET_USER_HOME/"

# set ownership
echo "Setting ownership of dotfiles to $TARGET_USER (will take effect after user creation)..."
run sudo chown -R 1000:users "$TARGET_USER_HOME/" 2>/dev/null || echo "Note: Will set proper ownership after rebuild"

# rebuild system
echo "Rebuilding NixOS..."
run sudo nixos-rebuild switch

# fix ownership after user creation
echo "Fixing ownership of dotfiles after user creation..."
run sudo chown -R "$TARGET_USER:users" "/home/$TARGET_USER/"

# exit message
echo "#-------------------------------------------#"
echo "Bootstrap complete. Reboot required."
echo "NOTE: A force shutdown may be required!"
echo ""
echo "Your new user is: $TARGET_USER"
echo "Your new hostname is: $TARGET_HOST"
echo "Don't forget to run 'sudo passwd $TARGET_USER' if you want to change the password!"
echo ""
echo "If you're using an Nvidia GPU, take a look at the Nvidia section of the README from my nixfiles repo before proceeding:"
echo "https://github.com/0lswitcher/nixfiles"
echo "Nvidia GPUs + Linux + Hyprland = Hell, but it's easy to maintain once you get it up and running. Just get ready for some troubleshooting to start."
echo "Look for commented sections of code in /etc/nixos/base.nix, and in ~/.config/hypr/hyprland.lua, uncomment these for a quick Nvidia configuration."
echo "You will also likely have to comment out the line in /etc/nixos/base.nix for pulling the latest linux kernel, as this commonly breaks Nvidia drivers."
echo ""
if [ "$INSTALL_TYPE" = "Full" ]; then
  echo "Don't forget to add 'docker' to extraGroups in base.nix!"
else
  echo "Don't forget to add 'docker' to extraGroups in base.nix if you ever decide to enable it!"
  echo ""
fi
echo "Theming will likely be incomplete until Pywal colors are generated once, so please do so at your nearest convenience either manually or with my scripts."
echo ""
echo "  Enjoy :) "
echo ""
echo "--- nix-bootstrap finished at $(date) ---"
echo "Full log saved to $LOG_FILE"
