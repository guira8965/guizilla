#!/bin/bash

### Disable BD Prochot 
echo "Disabling BD-Prochot..."

sudo modprobe msr
sudo wrmsr 0x1FC 0 -a

echo "BD-Prochot disabled."

### Enable IP Forwarding (for Tailscale)
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

echo "End of line."