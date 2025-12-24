#!/bin/bash

### Disable BD Prochot 
echo "Disabling BD-Prochot..."

sudo modprobe msr
sudo wrmsr 0x1FC 0 -a

echo "BD-Prochot disabled."

### Enable IP Forwarding (for Tailscale)
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

### Proxmox Logs
echo "Creating directories for pveproxy pvedaemon pve-cluster"
mkdir -p /var/log/pveproxy /var/log/pvedaemon /var/log/pve-cluster

echo "Changing permission for pveproxy"
mkdir -p /var/log/pveproxy
chown -R www-data:www-data /var/log/pveproxy
chmod 755 /var/log/pveproxy

### iptables for NAT
/sbin/iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -o vmbr0 -j MASQUERADE

echo "End of line."
