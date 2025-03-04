#!/bin/bash

# are you sure?
echo "This script will delete all snapper snapshots."
echo
echo "This is useful, for example, after a rollback with Timeshift that will break the connection with snapper snapshots."
echo
echo "Press y to continue or any other key to quit!" 
read -s -n 1 key
case $key in
    y|Y)
        echo "continuing..."
        ;;
    *)
        echo "exiting..."
        exit 1
        ;;
esac
echo

# ----- CLEANUP SNAPPER -----

# set default subvolume
echo "set default subvolume"
sudo btrfs subvolume set-default 5 /

# delete base subvolumes
echo "make sure to delete ALL existing snapper snapshot subvolumes..."
root_drive=$(sudo systemctl show --value --property=What -- -.mount |xargs basename)
temp_dir=$(mktemp -d --tmpdir=/tmp)
sudo mount /dev/$root_drive $temp_dir
echo "- first, remove all snapshots from ./snapshots/ subvolumes..."
for subvol in $(sudo btrfs subvolume list / | grep '/.snapshots/' | tac | awk '{print $9}'); do
    echo "  - deleting snapshot volume: /$subvol"
    sudo btrfs subvolume delete -c "$temp_dir/$subvol"
done
echo "- secondly, remove all ./snapshots subvolumes themselves..."
for subvol in $(sudo btrfs subvolume list / | grep '/.snapshots' | tac | awk '{print $9}'); do
    echo "  - deleting .snapshots volume: /$subvol"
    sudo btrfs subvolume delete -c "$temp_dir/$subvol"
done
sudo umount $temp_dir
sudo rmdir $temp_dir

# remove .snapshots paths if they still exist
echo "remove .snapshots paths if they still exist..."
[ -d "/.snapshots" ] && sudo rmdir "/.snapshots" > /dev/null 2>&1
[ -d "/home/.snapshots" ] && sudo rmdir "/home/.snapshots" > /dev/null 2>&1

# temporarily create .snapshots subvolumes in order to delete them properly with snapper
echo "temporarily create .snapshots subvolumes in order to delete them properly with snapper..."
sudo btrfs subvolume create /.snapshots
sudo btrfs subvolume create /home/.snapshots

# delete existing snapper configs
echo "delete existing snapper configurations..."
sudo snapper -c root delete-config
sudo snapper -c home delete-config

# re-create snapper configurations for root and home
echo "re-create snapper configurations..."
sudo snapper -c root create-config /
sudo snapper -c home create-config /home

# make sure to disable timeline snapshots for snapper configurations
echo "make sure to disable timeline snapshots for snapper configurations..."
sudo snapper -c root set-config TIMELINE_CREATE=no
sudo snapper -c home set-config TIMELINE_CREATE=no

# allow regular user to use snapper without root privileges
echo "allow regular user to use snapper without root privileges"
sudo snapper -c root set-config ALLOW_USERS=$USER SYNC_ACL=yes
sudo snapper -c home set-config ALLOW_USERS=$USER SYNC_ACL=yes

# ----- CREATE FIRST SNAPSHOT -----

# create first snapper snapshot
echo "create first snapper snapshot"
sudo snapper create -t single -d "FIRST-SNAPPER-SNAPSHOT"

# update GRUB configuration to make sure grub2 and grub-btrfs are up-to-date
echo "update GRUB configuration to make sure grub2 and grub-btrfs are up-to-date"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# ----- RESULTS -----

# show results
echo "final snapper configurations:"
echo
sudo snapper list-configs
echo
echo "root snapshots:"
sudo snapper -c root ls
echo
echo "home snapshots:"
sudo snapper -c home ls
echo
echo "snapper reset completed successfully!"
echo