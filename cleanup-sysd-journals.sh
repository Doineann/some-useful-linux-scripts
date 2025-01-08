#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script requires elevated privileges. Please run as root or use sudo."
    exit 1
fi

echo
echo -e "Systemd journal disk usage - before:"
sudo journalctl --disk-usage

echo -e "Cleaning up Systemd journal..."
sudo journalctl --vacuum-time=7d

echo
echo -e "Systemd journal disk usage - after:"
sudo journalctl --disk-usage
