#!/bin/bash
#
# Usage: ./comp.sh folder1 folder2
#
# The script:
#   1. Converts provided folder paths to absolute paths.
#   2. Recursively loops through all files in folder1 and compares them with those in folder2.
#      For each file in folder1, it extracts its relative path and finds the corresponding file in folder2.
#   3. While processing, it prints a progress indicator (overwritten on the same line) to stderr.
#      If a file’s name is too long, the beginning and the ending of the filename are shown.
#   4. Any missing or differing files are printed as new permanent lines.
#   5. A second pass compares folder2 against folder1 to report files missing in folder1.
#

# Check if two arguments were provided.
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 folder1 folder2"
    exit 1
fi

# Obtain absolute paths for the folders.
folder1=$(realpath "$1")
folder2=$(realpath "$2")

# Remove any trailing slashes.
folder1="${folder1%/}"
folder2="${folder2%/}"

echo "Folder 1: $folder1"
echo "Folder 2: $folder2"
echo ""

# Function to print a progress line to stderr.
# If the file name exceeds max characters, truncate it to show the first and last parts.
print_progress() {
    local file="$1"
    local max=60
    if [ "${#file}" -gt "$max" ]; then
        # Calculate half lengths (accounting for the ellipsis which is 3 characters)
        local half=$(( (max - 3) / 2 ))
        local prefix="${file:0:$half}"
        local suffix="${file: -$half}"
        file="${prefix}...${suffix}"
    fi
    # Print progress to stderr.
    # \r returns the cursor to the beginning of the line, and \033[K clears the line.
    printf "\r\033[KComparing: \"%s\"" "$file" >&2
}

echo "Comparing files from $folder1 against $folder2 ..."
# Loop through every file in folder1.
find "$folder1" -type f -print0 | while IFS= read -r -d '' file1; do
    # Extract the relative path: remove the folder1 prefix plus the slash.
    relPath="${file1#$folder1/}"
    file2="$folder2/$relPath"
    
    # Update progress for each file.
    print_progress "$file1"

    if [ ! -f "$file2" ]; then
         echo -e "\nMissing in $folder2: $file1"
    else
         # Perform a binary comparison using cmp.
         if ! cmp -s "$file1" "$file2"; then
             echo -e "\nDiscrepancy: $file1 and $file2 differ"
         fi
    fi
done

# End the progress line.
printf "\n\n"

echo "Comparing files from $folder2 against $folder1 for missing files..."
find "$folder2" -type f -print0 | while IFS= read -r -d '' file2; do
    relPath="${file2#$folder2/}"
    file1="$folder1/$relPath"
    
    # Update progress for each file.
    print_progress "$file2"

    if [ ! -f "$file1" ]; then
         echo -e "\nMissing in $folder1: $file2"
    fi
done
printf "\n"

echo "Comparison completed!"
