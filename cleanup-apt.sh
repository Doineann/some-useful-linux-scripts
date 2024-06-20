#!/bin/bash

if [ $EUID != 0 ]; then
    echo -e "This Script requires elevated privileges"
    sudo "$0" "$@"
    exit $?
fi

echo -e "Cleaning up apt packages..."
sudo apt --purge autoremove
