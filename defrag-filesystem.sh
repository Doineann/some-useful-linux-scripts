#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script requires elevated privileges. Please run as root or use sudo."
    exit 1
fi

echo "Checking filesystem..."
sudo e4defrag -c /

echo
read -p "Continue with defragmentation? "
if [ "$REPLY" != "y" ]; then
    exit
fi

echo "Defragmenting filesystem..."
sudo e4defrag  /
