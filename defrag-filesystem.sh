#!/bin/bash

if [ $EUID != 0 ]; then
    echo "This Script requires elevated privileges"
    sudo "$0" "$@"
    exit $?
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
