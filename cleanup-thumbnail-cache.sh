#!/bin/bash

echo
echo -e "Thumbnail Cache disk space - before:"
du -sh ~/.cache/thumbnails

echo
echo -e "Cleaning up Thumbnail Cache..."
rm -rf ~/.cache/thumbnails/*

echo
echo -e "Thumbnail Cache disk space - after:"
du -sh ~/.cache/thumbnails
