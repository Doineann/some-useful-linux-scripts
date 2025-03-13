#!/bin/bash

# github-fetch-latest-artifact.sh
#
# Downloads the latest version of a specific repository's artifact on Github.
#
# Usage:
#   ./github-fetch-latest-artifact.sh [github user] [github repo] [part of filename] [options]
#
# Options:
#   --show-tag      : Prints the artifact tag name
#   --show-filename : Prints the artifact filename
#   --show-url      : Prints the artifact URL
#                     (Multiple --show-* options can be combined)
#   --download      : Downloads the artifact to the current directory or specified output directory
#   --outputdir     : Specifies the output directory for download (used with --download)
#

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 [github user] [github repo] [part of filename] [--show-tag] [--show-filename] [--show-url] [--download [--outputdir path]]"
    exit 1
fi

GITHUB_USER="$1"
GITHUB_REPO="$2"
TARGET_NAME_SEARCH="$3"
shift 3

GITHUB_LATEST_API_URL="https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/latest"

# fetch latest release information
LATEST_RELEASE_JSON=$(curl -s "$GITHUB_LATEST_API_URL")

# extract tag name
ARTIFACT_TAGNAME=$(echo "$LATEST_RELEASE_JSON" | grep 'tag_name' | awk -F '"' '{print $4}')

# extract artifact URL and filename
ARTIFACT_URL=$(echo "$LATEST_RELEASE_JSON" | grep 'browser_download_url' | grep "$TARGET_NAME_SEARCH" | awk -F '"' '{print $4}')
ARTIFACT_FILENAME=$(basename "$ARTIFACT_URL")

# trim spaces
ARTIFACT_TAGNAME=$(echo "$ARTIFACT_TAGNAME" | xargs)
ARTIFACT_FILENAME=$(echo "$ARTIFACT_FILENAME" | xargs)
ARTIFACT_URL=$(echo "$ARTIFACT_URL" | xargs)

# handle options
SHOW_TAG=false
SHOW_FILENAME=false
SHOW_URL=false

OUTPUT_DIR="."

while [ "$#" -gt 0 ]; do
    case "$1" in
        --show-tag)
            SHOW_TAG=true ;;
        --show-filename)
            SHOW_FILENAME=true ;;
        --show-url)
            SHOW_URL=true ;;
        --download)
            # if there's a path after --download, use it; otherwise, default to current directory
            if [ -d "$2" ]; then
                OUTPUT_DIR="$2"
                shift
            fi
            if [ -n "$ARTIFACT_URL" ]; then
                OUTPUT_PATH="$OUTPUT_DIR/$ARTIFACT_FILENAME"
                echo "Downloading $ARTIFACT_URL ..."
                wget --progress=bar -O "$OUTPUT_PATH" "$ARTIFACT_URL" > /dev/null
                exit 0
            else
                echo "Error: No artifact found"
                exit 2
            fi ;;
        *)
            echo "Unknown option: $1"
            exit 1 ;;
    esac
    shift
done

# if no --show-* options are passed, print all values
if ! $SHOW_TAG && ! $SHOW_FILENAME && ! $SHOW_URL; then
    SHOW_TAG=true
    SHOW_FILENAME=true
    SHOW_URL=true
fi

# print selected values
[ "$SHOW_TAG" = true ] && [ -n "$ARTIFACT_TAGNAME" ] && echo "$ARTIFACT_TAGNAME"
[ "$SHOW_FILENAME" = true ] && [ -n "$ARTIFACT_FILENAME" ] && echo "$ARTIFACT_FILENAME"
[ "$SHOW_URL" = true ] && [ -n "$ARTIFACT_URL" ] && echo "$ARTIFACT_URL"

# exit with error if no filename was found
if [ -z "$ARTIFACT_FILENAME" ]; then
    exit 2
fi

exit 0
