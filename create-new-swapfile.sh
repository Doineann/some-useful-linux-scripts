#!/bin/bash

# Configurable swap file location
SWAPFILE="/swapfile"

# Default size in megabytes
DEFAULT_SWAP_SIZE=2048

# Check if the script is run with elevated privileges
if [ $EUID != 0 ]; then
    echo "This Script requires elevated privileges"
    sudo "$0" "$@"
    exit $?
fi

# If an argument is provided, use it as the swap file size (otherwise, use default)
if [ -n "$1" ]; then
    SWAP_SIZE=$1
else
    SWAP_SIZE=$DEFAULT_SWAP_SIZE
fi

echo
echo "Detecting typical swap locations ..."
# Determine if there is a swapfile
location_swapfile=$(swapon --show=NAME,SIZE,UUID --noheadings --bytes --raw | awk '/swap/,0' | cut -d' ' -f1)
[[ -z "$location_swapfile" ]] && echo "-> No swapfile found" || echo "-> Swapfile found at $location_swapfile!"

echo
echo "Disabling swap ..."
swapoff -a

if [ -z "$location_swapfile" ]; then
    echo "No existing swapfile detected. Using default location: $SWAPFILE"
    location_swapfile=$SWAPFILE
    echo
    echo "Creating swapfile of size $SWAP_SIZE MB ..."
    sudo dd if=/dev/zero of=$location_swapfile bs=1M count=$SWAP_SIZE status=progress
    sudo chmod 600 $location_swapfile
    sudo mkswap $location_swapfile
else
    echo "Existing swapfile detected at $location_swapfile"
    if [ -n "$1" ]; then
        echo "Updating swapfile size to $SWAP_SIZE MB ..."
        rm $location_swapfile
        sudo dd if=/dev/zero of=$location_swapfile bs=1M count=$SWAP_SIZE status=progress
        sudo chmod 600 $location_swapfile
        sudo mkswap $location_swapfile
    else
        echo "No size specified, leaving the existing swapfile untouched."
    fi
fi

echo
echo "Enabling swap again ..."
swapon $location_swapfile
