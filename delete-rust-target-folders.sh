#!/bin/bash

echo "The following folders will be removed:"

find . -name target -type d -exec echo rm -rf {} \;

echo "Do you want to continue? (y/n)"
read input
if [ "$input" == "y" ]
then
    find . -name target -type d -prune -exec rm -rf {} \;
fi
