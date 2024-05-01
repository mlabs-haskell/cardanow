#!/usr/bin/env bash

###########################################################################################
# Description: This script iterates over a list of directories and cleans up              #
#              files in each directory, keeping only the specified number of              #
#              most recent files. It is useful for managing disk space by                 #
#              removing old files in directories where new files are                      #
#              frequently generated.                                                      #
#                                                                                         #
###########################################################################################

# Check if the number of arguments is correct
if [ $# -lt 2 ]; then
    echo "Usage: $0 <files_to_keep> <list_of_dirs>"
    exit 1
fi

# Number of most recent files to keep
files_to_keep="$1"
# List of paths to iterate over
paths=("${@:2}")

# Save the current directory to the stack
pushd .

# Function to clean up files in a directory
clean_up_directory() {
    local directory="$1"

    # Change directory to the specified directory
    pushd "$directory" || { echo "Error: Could not change directory to $directory"; return 1; }

    # List files, sort by modification time (newest first), and skip the first n
    # shellcheck disable=SC2012,SC2004
    files_to_delete=$(ls -t | tail -n +$(($files_to_keep + 1)))

    # Delete files except for the n most recent ones
    echo -e "${files_to_delete}" | xargs rm -fr
    echo "Deleted file: ${files_to_delete}"

    # Return to the original directory
    popd || { echo "Error: Could not return to the original directory"; return 1; }
}

# Iterate over each path and clean up files
for path in "${paths[@]}"; do
    echo "Cleaning up files in directory: $path"
    clean_up_directory "$path"
done

echo "Cleanup completed."

refresh-available-snapshots-state
