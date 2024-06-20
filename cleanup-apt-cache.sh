#!/bin/bash

if [ $EUID != 0 ]; then
    echo -e "This Script requires elevated privileges"
    sudo "$0" "$@"
    exit $?
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
