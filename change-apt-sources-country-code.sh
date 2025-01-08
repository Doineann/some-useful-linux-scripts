#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script requires elevated privileges. Please run as root or use sudo."
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 <country-code|none>"
    exit 1
fi

COUNTRY_CODE="$1"

if [[ "$COUNTRY_CODE" != "none" && ! "$COUNTRY_CODE" =~ ^[a-z]{2}$ ]]; then
    echo "Invalid country code. Please provide a valid two-letter country code or use 'none' to remove the country code."
    exit 1
fi

TIMESTAMP=$(date +%Y_%m_%d_%H%M%S)

update_urls() {
    FILE="$1"
    if [ ! -f "$FILE" ]; then
        return
    fi
    echo "Updating $FILE..."
    cp "$FILE" "$FILE.$TIMESTAMP.bak"
    if [ "$COUNTRY_CODE" == "none" ]; then
        # If no country code, remove any 2-letter country code (ignore comments)
        sed -i '/^[^#]/s|http://[a-zA-Z][a-zA-Z]\.\(.*\)\.ubuntu\.com|http://\1.archive.ubuntu.com|g' "$FILE"
    else
        # First pass: replace country code (ignore comments)
        sed -i "/^[^#]/s|http://\([a-zA-Z]\{2\}\)\.\([a-zA-Z0-9.-]*\)\.archive.ubuntu.com/|http://$COUNTRY_CODE.\2.archive.ubuntu.com/|g" "$FILE"
        # Second pass: add country code only if missing (ignore comments)
        sed -i "/^[^#]/ {/http:\/\/[a-zA-Z0-9.-]*\.archive.ubuntu\.com\// { /http:\/\/[a-zA-Z]\{2\}\./! s|http://|http://$COUNTRY_CODE.| } }" "$FILE"
    fi
    echo "Backup of original file saved as $FILE.$TIMESTAMP.bak"
}

if [ -f /etc/apt/sources.list ]; then
    update_urls "/etc/apt/sources.list"
else
    echo "/etc/apt/sources.list not found."
fi

if [ -d /etc/apt/sources.list.d/ ]; then
    for source_file in /etc/apt/sources.list.d/*; do
        [[ "$source_file" == *.bak ]] && continue
        update_urls "$source_file"
    done
else
    echo "/etc/apt/sources.list.d/ directory not found."
fi

if [ "$COUNTRY_CODE" == "none" ]; then
    echo "Removed country codes from Ubuntu apt mirrors."
else
    echo "Added or replaced country code $COUNTRY_CODE to Ubuntu apt mirrors."
fi
