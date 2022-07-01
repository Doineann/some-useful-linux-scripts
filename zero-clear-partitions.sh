#!/bin/bash

if [ $EUID != 0 ]; then
    echo "This Script requires elevated privileges"
    sudo "$0" "$@"
    exit $?
fi

echo 
echo "Detecting typical swap locations ..."
# determine if there is a swapfile
location_swapfile=$(swapon -s | awk '/swap/,0' | cut -d' ' -f1)
# determine if there is a swap partition on sda, sdb or sdc
location_swappart_sda=$(swapon -s | awk '/sda/,0' | cut -d' ' -f1)
location_swappart_sdb=$(swapon -s | awk '/sdb/,0' | cut -d' ' -f1)
location_swappart_sdc=$(swapon -s | awk '/sdc/,0' | cut -d' ' -f1)
[[ -z "$location_swapfile" ]] && echo "-> No swapfile found" || echo "-> Swapfile found at $location_swapfile !"
[[ -z "$location_swappart_sda" ]] && echo "-> No swap parition found on sda" || echo "-> Swap paritition found at $location_swappart_sda !"
[[ -z "$location_swappart_sdb" ]] && echo "-> No swap parition found on sdb" || echo "-> Swap paritition found at $location_swappart_sdb !"
[[ -z "$location_swappart_sdc" ]] && echo "-> No swap parition found on sdc" || echo "-> Swap paritition found at $location_swappart_sdc !"

echo 
echo "Disabling swap ..."
swapoff -v -a

if [ -z "$location_swapfile" ]
then
    : # nothing to be done
else
	echo
	echo "Removing swapfile ..."
	rm $location_swapfile
fi

if [ -z "$location_swappart_sda" ]
then
    : # nothing to be done
else
	echo
	echo "Zeroing swap partition at $location_swappart_sda ..."
	dd if=/dev/zero of=$location_swappart_sda bs=1024k obs=512 seek=1 status=progress
fi

if [ -z "$location_swappart_sdb" ]
then
    : # nothing to be done
else
	echo
	echo "Zeroing swap partition at $location_swappart_sdb ..."
    dd if=/dev/zero of=$location_swappart_sdb bs=1024k obs=512 seek=1 status=progress
fi

if [ -z "$location_swappart_sdc" ]
then
    : # nothing to be done
else
	echo
	echo "Zeroing swap partition at $location_swappart_sdc ..."
	dd if=/dev/zero of=$location_swappart_sdc bs=1024k obs=512 seek=1 status=progress
fi

echo
echo "Zeroing free space on system drive ..."
dd if=/dev/zero of=/var/tmp/bigemptyfile bs=16384k status=progress
rm /var/tmp/bigemptyfile

if [ -z "$location_swapfile" ]
then
    : # nothing to be done
else
	echo
	echo "Recreating swapfile ..."
	sudo dd if=/dev/zero of=$location_swapfile bs=1024 count=2097152 status=progress
	sudo chmod 600 $location_swapfile
	sudo mkswap $location_swapfile
fi

echo
read -p "Enable swap again? "
if [ "$REPLY" == "y" ]; then
    swapon -v -a
fi
