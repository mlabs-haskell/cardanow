#!/usr/bin/env bash

# List of directories to delete
directories=("cardano-node-data" "s3-volume" "exported-snapshots" "mithril-snapshots" "kupo-data")

# Confirmation prompt
read -rp "Are you sure you want to delete the following directories: ${directories[*]}? (y/n): " answer

# Check user's response
if [[ $answer != "y" ]]; then
    echo "Operation cancelled by user."
    exit 1
fi

# Loop through each directory and delete it if it exists
for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        echo "Deleting $dir..."
        rm -rf "$dir"
        echo "Directory $dir deleted."
    else
        echo "Directory $dir does not exist."
    fi
done
