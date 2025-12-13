#!/bin/bash

### Names for each features.
SERVER_OPTIMIZATION="gui-optimization"
MC_SERVER_AUTOMATION="gui-mc-servers"
TARGET_USER="${SUDO_USER:-username}"

### Check if script is running with root previleges, if not then prompt for elevation.
if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges. Attempting to re-run with sudo..."
    exec sudo bash "$0" "$@"
    exit 1
fi
echo "Script is running with root previleges."

read -p "Press ENTER to continue..."

### Create directories, just in case they don't exist.
mkdir -p /usr/local/bin
mkdir -p $HOME/.config/systemd/user

### Install script and systemd service for server optimization
echo "Moving $SERVER_OPTIMIZATION.sh to /usr/local/bin/$SERVER_OPTIMIZATION.sh"
cp Features/server-optimization/script.sh /usr/local/bin/$SERVER_OPTIMIZATION.sh
echo "Moving $MC_SERVER_AUTOMATION.service to $HOME/.config/systemd/user/$MC_SERVER_AUTOMATION.service"
cp Features/mc-servers/service.service $HOME/.config/systemd/user/$MC_SERVER_AUTOMATION.service

### Reload Systemd
echo "Reloading systemd."
systemctl daemon-reload

### Enable systemd services (root)
echo "Enabling and starting $SERVER_OPTIMIZATION.service"
systemctl enable --now $SERVER_OPTIMIZATION.service
echo "Enabling and starting $MC_SERVER_AUTOMATION.service"

### Check if script is running with root previleges, if so then disregard.
if [ "$EUID" -eq 0 ]; then
    echo "Script is running as root. Dropping privileges to $TARGET_USER..."
    exec sudo -u "$TARGET_USER" bash "$0" "$@"
fi
echo "Script is running with user level previleges."

### Enable systemd services (user-level)
systemctl --user daemon-reload
systemctl --user enable --now $MC_SERVER_AUTOMATION.service

### EOL
read -p "Press ENTER to exit."
echo "Install script complete."