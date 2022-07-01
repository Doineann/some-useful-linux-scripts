#!/bin/bash

if [ $EUID != 0 ]; then
    echo -e "This Script requires elevated privileges"
    sudo "$0" "$@"
    exit $?
fi

echo -e "Cleaning up APT cache..."
sudo apt-get clean

echo -e "Autoremoving packages..."
sudo apt --purge autoremove

echo
echo -e "Done! Press a key to quit..."
read -n 1
