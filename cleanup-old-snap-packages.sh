#!/bin/bash

if [ $EUID != 0 ]; then
    echo -e "This Script requires elevated privileges"
    sudo "$0" "$@"
    exit $?
fi

echo
echo -e "Snap packages disk usage - before:"
du -h /var/lib/snapd/snaps

echo
echo -e "Cleaning up old Snap packages..."
# Removes old revisions of snaps
set -eu
snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done

echo
echo -e "Snap packages disk usage - after:"
du -h /var/lib/snapd/snaps
