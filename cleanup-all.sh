#!/bin/bash

sudo ./cleanup-apt.sh
sudo ./cleanup-apt-cache.sh
sudo ./cleanup-old-snap-packages.sh
sudo ./cleanup-sysd-journals.sh

./cleanup-thumbnail-cache.sh

echo
echo -e "Done! Press a key to quit..."
read -n 1
