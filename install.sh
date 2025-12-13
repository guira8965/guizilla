#!/bin/bash

### Names for each features.
SERVER_OPTIMIZATION="gui-optimization"
MC_SERVER_AUTOMATION="gui-mc-servers"
TARGET_USER="${SUDO_USER:-$1}"

### Introduction
echo "The scripts will be installed under the user $TARGET_USER"

### Check if script is running with root previleges, if not then prompt for elevation.
if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges. Re-run with sudo."
    exit 1
fi
echo "Script is running with root previleges."

read -p "Press ENTER to continue..."

# Create directories
mkdir -p /usr/local/bin
sudo -u "$TARGET_USER" mkdir -p "/home/$TARGET_USER/.config/systemd/user/default.target.wants"

# Copy scripts/services
echo "Installing $SERVER_OPTIMIZATION script..."
cp Features/server-optimization/script.sh /usr/local/bin/$SERVER_OPTIMIZATION.sh
chmod +x /usr/local/bin/$SERVER_OPTIMIZATION.sh

echo "Installing $MC_SERVER_AUTOMATION service for user..."
cp Features/mc-servers/service.service "/home/$TARGET_USER/.config/systemd/user/$MC_SERVER_AUTOMATION.service"
chown "$TARGET_USER:$TARGET_USER" "/home/$TARGET_USER/.config/systemd/user/$MC_SERVER_AUTOMATION.service"

# Reload root-level systemd and enable optimization service
echo "Reloading systemd and enabling root-level service..."
systemctl daemon-reload
systemctl enable --now $SERVER_OPTIMIZATION.service

# Enable lingering for user to allow user services without login
loginctl enable-linger "$TARGET_USER"

# Reload user-level systemd and enable user service
echo "Enabling user-level Minecraft service..."
sudo -u "$TARGET_USER" XDG_RUNTIME_DIR="/run/user/$(id -u $TARGET_USER)" \
    systemctl --user daemon-reload
sudo -u "$TARGET_USER" XDG_RUNTIME_DIR="/run/user/$(id -u $TARGET_USER)" \
    systemctl --user enable --now $MC_SERVER_AUTOMATION.service

### EOL
read -p "Press ENTER to exit."
echo "Installation complete."