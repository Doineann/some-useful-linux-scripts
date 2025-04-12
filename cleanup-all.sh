#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script requires elevated privileges. Please run as root or use sudo."
    exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo $SCRIPT_DIR

sudo $SCRIPT_DIR/cleanup-apt.sh
sudo $SCRIPT_DIR/cleanup-apt-cache.sh
sudo $SCRIPT_DIR/cleanup-old-snap-packages.sh
sudo $SCRIPT_DIR/cleanup-sysd-journals.sh

$SCRIPT_DIR/cleanup-thumbnail-cache.sh

echo
echo -e "Done! Press a key to quit..."
read -n 1
