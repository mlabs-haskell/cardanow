#!/usr/bin/env bash

################################################################################
# Description: Bash script to delete old files from specified S3 paths.        #
################################################################################

# Check if all parameters are provided
if [ $# -lt 3 ]; then
    echo "Usage: $0 <ENTRYPOINT_URL> <files_to_keep> <path1> <path2> ..."
    exit 1
fi

# Assign parameters to variables
ENTRYPOINT_URL="$1"
files_to_keep="$2"
shift 2
paths_to_check=("$@")

# Define the S3 bucket
BUCKET="cardanow"

# Check if files_to_keep and at least one path are provided
if [ "$files_to_keep" -eq 0 ] || [ -z "$files_to_keep" ] || [ ${#paths_to_check[@]} -eq 0 ]; then
    echo "Error: 'files_to_keep' must be a non-zero positive integer."
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
