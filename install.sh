#!/bin/bash

### Names for each features.
SERVER_OPTIMIZATION="gui-optimization"
MC_SERVER_AUTOMATION="gui-mc-servers"
CURRENT_USER="/home/$1"

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
mkdir -p $CURRENT_USER/.config/systemd/user

### Install script and systemd service for server optimization
echo "Moving $SERVER_OPTIMIZATION.sh to /usr/local/bin/$SERVER_OPTIMIZATION.sh"
cp Features/server-optimization/script.sh /usr/local/bin/$SERVER_OPTIMIZATION.sh
echo "Moving $SERVER_OPTIMIZATION.service to /etc/systemd/system/$SERVER_OPTIMIZATION.service"
cp Features/server-optimization/service.service /etc/systemd/system/$SERVER_OPTIMIZATION.service

### Install script and systemd service for minecraft server automization
echo "Moving $MC_SERVER_AUTOMATION.sh to /usr/local/bin/$CURRENT_USER/$MC_SERVER_AUTOMATION.sh"
cp Features/mc-servers/script.sh /usr/local/bin/$MC_SERVER_AUTOMATION.sh
echo "Moving $MC_SERVER_AUTOMATION.service to $CURRENT_USER/.config/systemd/user/$MC_SERVER_AUTOMATION.service"
cp Features/mc-servers/service.service $CURRENT_USER/.config/systemd/user/$MC_SERVER_AUTOMATION.service

### Reload Systemd
echo "Reloading systemd."
systemctl daemon-reload
sudo -u $1 systemctl --user daemon-reload

### Enable systemd services
echo "Enabling and starting $SERVER_OPTIMIZATION.service"
systemctl enable --now $SERVER_OPTIMIZATION.service
echo "Enabling and starting $MC_SERVER_AUTOMATION.service"
sudo -u $1 systemctl --user enable --now $MC_SERVER_AUTOMATION.service

### EOL
read -p "Press ENTER to exit."
echo "Install script complete."