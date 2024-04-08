#!/usr/bin/env bash

################################################################################
# Description: Bash script to delete old files from specified S3 paths.        #
# Usage:       ./script.sh <files_to_keep> <path1> <path2> ...                #
################################################################################
# TODO handle all env vars with nix
export ENTRYPOINT_URL=https://5c90369860b916812808cd543a1d782b.r2.cloudflarestorage.com


# Define the S3 bucket
BUCKET="cardanow"

# Get files_to_keep and paths_to_check from command line arguments
files_to_keep="$1"
shift
paths_to_check=("$@")

# Check if files_to_keep and at least one path are provided
if [[ -z "$files_to_keep" || ${#paths_to_check[@]} -eq 0 ]]; then
    echo "Usage: $0 <files_to_keep> <path1> <path2> ..."
    exit 1
fi

# Loop through each path provided
for path in "${paths_to_check[@]}"; do
    # Get a list of files to delete for the current path
    files_to_delete=$(aws --output json --endpoint-url="${ENTRYPOINT_URL}" s3api list-objects --bucket "$BUCKET" --prefix "$path" | \
                      jq -r --argjson files_to_keep "$files_to_keep" '.["Contents"] | sort_by(.LastModified) | .[:-($files_to_keep | tonumber)][].Key')

    # Loop through each file to delete
    for file in $files_to_delete; do
        # Delete the file
        aws --endpoint-url="${ENTRYPOINT_URL}" s3 rm "s3://$BUCKET/$file"
        echo "Deleted: $file"
    done
done
