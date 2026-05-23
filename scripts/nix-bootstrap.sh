#!/usr/bin/env bash
# post-install.sh - script to run post NixOS installation

set -euo pipefail

REPO_DIR="/tmp/nix-bootstrap"
DOTFILES_REPO="https://github.com/0lswitcher/dotfiles.git"
NIXFILES_REPO="https://github.com/0lswitcher/nixfiles.git"
WALLPAPERS_REPO="https://github.com/0lswitcher/wallpapers.git"
NIXOS_DIR="/etc/nixos"

prompt() {
    local message="$1"
    shift
    local options=("$@")
    local choice
    
    echo "$message" >&2  # send prompt to stderr so it doesn't interfere with return value
    select choice in "${options[@]}"; do
        if [[ -n "$choice" ]]; then
            echo "$choice"  # goes to stdout
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

cat << "EOF"

                           
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

echo "Selected mode: $MODE"  # debug output

if [ "$MODE" = "Online" ]; then
    echo "Running in Online mode - cloning repositories..."
    clone_or_update_repo "$DOTFILES_REPO" "$REPO_DIR/dotfiles"
    clone_or_update_repo "$NIXFILES_REPO" "$REPO_DIR/nixfiles"
else
    echo "Running in Offline mode..."
    read -rp "Enter the path where offline repos are located: " OFFLINE_PATH
    REPO_DIR="$OFFLINE_PATH"
fi

# install type prompt
INSTALL_TYPE=$(prompt "Select installation type:" "Server" "Minimal" "Full")
echo "Selected installation type: $INSTALL_TYPE"  # debug output

# hardware type prompt
HW_TYPE=$(prompt "Select hardware:" "Desktop" "Laptop")
echo "Selected hardware type: $HW_TYPE"  # debug output

# get target username
read -rp "Enter the username for your new user (this will replace 'changeme' in base.nix): " TARGET_USER
if [[ -z "$TARGET_USER" ]]; then
    echo "Error: Username cannot be empty"
    exit 1
fi
echo "Selected username: $TARGET_USER"

# get target hostname
read -rp "Enter the new hostname for your machine (not to be confused w/ username): " TARGET_HOST
if [[ -z "$TARGET_HOST" ]]; then
    echo "Error: Hostname cannot be empty"
    exit 1
fi
echo "Selected Hostname: $TARGET_HOST"

# wallpaper prompt
BG_PULL=$(prompt "Would you like to include my wallpaper collection in your final build?" "Hell yeah" "Fuck no")
if [ "$BG_PULL" = "Hell yeah" ]; then
    echo "Sweet, pulling wallpapers from repository now..."
    clone_or_update_repo "$WALLPAPERS_REPO" "/home/$TARGET_USER/stuff/pictures/backgrounds"
else
    echo "No worries, skipping wallpapers and moving on to dotfiles."
fi

# extract stateVersion from existing configuration.nix before overwriting it
echo "Extracting system.stateVersion from existing configuration..."
NIXOS_VER=$(grep "system.stateVersion" "$NIXOS_DIR/configuration.nix" 2>/dev/null || true)

# write configuration.nix
echo "Generating configuration.nix with imports..."
sudo cp "$REPO_DIR/nixfiles/base.nix" "$NIXOS_DIR/base.nix"
sudo cp "$REPO_DIR/nixfiles/roles/${INSTALL_TYPE,,}.nix" "$NIXOS_DIR/role.nix"

# replace 'changeme' with actual username in base.nix
echo "Updating username in base.nix from 'changeme' to '$TARGET_USER'..."
sudo sed -i "s/changeme/$TARGET_USER/g" "$NIXOS_DIR/base.nix"

# replace 'CHANGEME' with actual hostname in base.nix
echo "Updating hostname in base.nix from 'CHANGEME' to '$TARGET_HOST'..."
sudo sed -i "s/CHANGEME/$TARGET_HOST/g" "$NIXOS_DIR/base.nix"

# create configuration.nix dynamically
sudo tee "$NIXOS_DIR/configuration.nix" > /dev/null <<EOF
{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
    ./role.nix
    ./hardware-configuration.nix
  ];

EOF

# append configuration.nix w/ nixos ver. extracted from original file
if [[ -n "$NIXOS_VER" ]]; then
    echo "Adding system.stateVersion: $NIXOS_VER"
    echo "  $NIXOS_VER" | sudo tee -a "$NIXOS_DIR/configuration.nix" > /dev/null
    echo "}" | sudo tee -a "$NIXOS_DIR/configuration.nix" > /dev/null
else
    echo "Warning: Could not find system.stateVersion in original configuration.nix"
    echo "You may need to add it manually or run nixos-generate-config first"
fi

# apply dotfiles
echo "Applying dotfiles for $HW_TYPE to future user $TARGET_USER..."
TARGET_USER_HOME="/home/$TARGET_USER"

# create the target user's home directory and .config if they don't exist
sudo mkdir -p "$TARGET_USER_HOME/.config"

# copy dotfiles to target user's home and clean up after
sudo cp -r "$REPO_DIR/dotfiles/dots/." "$TARGET_USER_HOME/.config/"
sudo cp -r "$REPO_DIR/dotfiles/cache/wal/" "$TARGET_USER_HOME/.cache/"
if [ "$HW_TYPE" = "Laptop" ]; then
    sudo rm -rf "$TARGET_USER_HOME/.config/waybar/"
    sudo cp -r "$TARGET_USER_HOME/.config/laptop-specific/waybar/" "$TARGET_USER_HOME/.config/"
    sudo rm -rf "$TARGET_USER_HOME/.config/laptop-specific/"
else
    sudo rm -rf "$TARGET_USER_HOME/.config/laptop-specific/"
fi
if [ "$INSTALL_TYPE" = "Server" ]; then
    sudo rm -rf "$TARGET_USER_HOME/.config/hypr/"
    sudo rm -rf "$TARGET_USER_HOME/.config/waybar/"
    sudo rm -rf "$TARGET_USER_HOME/.config/laptop-specific/"
    sudo rm -rf "$TARGET_USER_HOME/.config/qt6ct/"
    sudo rm -rf "$TARGET_USER_HOME/.config/ulauncher/"
fi
sudo rm -rf "$TARGET_USER_HOME/.config/dots"
echo "Dotfiles successfully applied to $TARGET_USER_HOME/.config/"

# set proper ownership for the target user (this will work after rebuild when user exists)
echo "Setting ownership of dotfiles to $TARGET_USER (will take effect after user creation)..."
sudo chown -R 1000:users "$TARGET_USER_HOME/" 2>/dev/null || echo "Note: Will set proper ownership after rebuild"

# rebuild system
echo "Rebuilding NixOS..."
sudo nixos-rebuild switch

# fix ownership after user creation
echo "Fixing ownership of dotfiles after user creation..."
sudo chown -R "$TARGET_USER:users" "/home/$TARGET_USER/"

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
echo ""
if [ "$INSTALL_TYPE" = "Full" ]; then
    echo "Don't forget to add 'docker' to extraGroups in base.nix!"
else
    echo "Don't forget to add 'docker' to extraGroups in base.nix if you ever decide to enable it!"
fi
echo ""
echo "  Enjoy :) "
