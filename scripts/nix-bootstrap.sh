#!/usr/bin/env bash
# post-install.sh - script to run post NixOS installation

set -euo pipefail

REPO_DIR="/tmp/nix-bootstrap"
DOTFILES_REPO="https://github.com/0lswitcher/dotfiles.git"
NIXFILES_REPO="https://github.com/0lswitcher/nixfiles.git"
NIXOS_DIR="/etc/nixos"
NIXOS_VER="cat /etc/nixos/configuration.nix | grep 'system.stateVersion'"

prompt() {
    local message="$1"
    shift
    local options=("$@")
    local choice
    echo "$message"
    select choice in "${options[@]}"; do
        echo "$choice"
        return
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

# online / offline
if ping -c 1 github.com &>/dev/null; then
    MODE=$(prompt "Choose installation mode:" "Online" "Offline")
else
    echo "No internet connection detected. Defaulting to Offline mode."
    MODE="Offline"
fi

if [ "$MODE" = "Online" ]; then
    clone_or_update_repo "$DOTFILES_REPO" "$REPO_DIR/dotfiles"
    clone_or_update_repo "$NIXFILES_REPO" "$REPO_DIR/nixfiles"
else
    read -rp "Enter the path where offline repos are located: " OFFLINE_PATH
    REPO_DIR="$OFFLINE_PATH"
fi

# install type
INSTALL_TYPE=$(prompt "Select installation type:" "Server" "Minimal" "Full")

# hardware type
HW_TYPE=$(prompt "Select hardware:" "Desktop" "Laptop")

# write configuration.nix
echo "Generating configuration.nix with imports..."
sudo cp "$REPO_DIR/nixfiles/base.nix" "$NIXOS_DIR/base.nix"
sudo cp "$REPO_DIR/nixfiles/roles/${INSTALL_TYPE,,}.nix" "$NIXOS_DIR/role.nix"

# create configuration.nix dynamically
sudo tee "$NIXOS_DIR/configuration.nix" > /dev/null <<EOF
{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
    ./role.nix
    ./hardware-configuratuion.nix
  ];
}
EOF

# append configuration.nix w/ nixos ver. generated on initial install
cat /etc/nixos/configuration.nix >> "$NIXOS_VER"

# apply dotfiles
echo "Applying dotfiles for $HW_TYPE..."
USER_HOME="/home/$USER"
cp -r -f "$REPO_DIR/dotfiles/." "$HOME/.config/"

if [ "HW_TYPE" = "Laptop" ]; then
    sudo rm -R "$HOME/.config/waybar/"
    cp -r -f "$HOME/.config/laptop-specific/waybar/" "$HOME/.config/"
fi

echo "Dotfiles successfully applied."
chown -R "$USER:$GROUPS" "$HOME"
echo "Permissions granted for dotfile usage."

# rebuild system
echo "Rebuilding NixOS..."
sudo nixos-rebuild switch

# exit message
echo "Bootstrap complete. Reboot recommended. Don't forget to run passwd!"
echo " ~ If you're using an Nvidia GPU, take a look at base.nix before doing so-and do research, since Nvidia GPUs + Linux + Hyprland = Hell"

if [ "$INSTALL_TYPE" = "Full" ]; then
    echo "Don't forget to add 'docker' to extraGroups in base.nix!"
else
    echo "Don't forget to add 'docker' to extraGroups in base.nix if you decide to enable it!"
fi

echo "  Enjoy :) "
