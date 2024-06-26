#!/bin/bash

if [ $EUID != 0 ]; then
    echo -e "This Script requires elevated privileges"
    sudo "$0" "$@"
    exit $?
fi

echo
echo -e "Systemd journal disk usage - before:"
sudo journalctl --disk-usage

echo -e "Cleaning up Systemd journal..."
sudo journalctl --vacuum-time=7d

echo
echo -e "Systemd journal disk usage - after:"
sudo journalctl --disk-usage
