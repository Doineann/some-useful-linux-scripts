#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script requires elevated privileges. Please run as root or use sudo."
    exit 1
fi

echo
echo -e "APT Cache disk usage - before:"
sudo du -sh /var/cache/apt 

echo
echo -e "Cleaning up APT Cache..."
sudo apt-get clean

echo
echo -e "APT Cache disk usage - after:"
sudo du -sh /var/cache/apt 
