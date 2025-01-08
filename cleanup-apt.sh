#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script requires elevated privileges. Please run as root or use sudo."
    exit 1
fi

echo -e "Cleaning up apt packages..."
sudo apt --purge autoremove
