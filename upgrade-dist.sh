#!/bin/bash

if [ $EUID != 0 ]; then
    echo "This Script requires elevated privileges"
    sudo "$0" "$@"
    exit $?
fi

echo "Checking if there is an upgrade for this distro..."
sudo do-release-upgrade -c

echo "Do you wish to install this upgrade?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo do-release-upgrade; break;;
        No ) exit;;
    esac
done

echo
echo -e "Done! Press a key to quit..."
read -n 1
