#!/usr/bin/env bash

################################################################################
# Description: Bash script to delete old files from specified S3 paths.        #
################################################################################

# Check if all parameters are provided
if [ $# -lt 3 ]; then
    echo "Usage: $0 <BUCKET_NAME> <FILES_TO_KEEP> <PATH1> <PATH2> ..."
    exit 1
fi

# Assign parameters to variables
bucket_name="$1"
files_to_keep="$2"
shift 2
paths_to_check=("$@")

# Check if files_to_keep and at least one path are provided
if [ "$files_to_keep" -eq 0 ] || [ -z "$files_to_keep" ] || [ ${#paths_to_check[@]} -eq 0 ]; then
    echo "Error: 'files_to_keep' must be a non-zero positive integer."
    exit 1
fi

# Loop through each path provided
for path in "${paths_to_check[@]}"; do
    # Get a list of files to delete for the current path
    files_to_delete=$(aws --output json s3api list-objects --bucket "${bucket_name}" --prefix "${path}" | \
                          jq -r --argjson files_to_keep "$files_to_keep" 'try (.["Contents"] // empty) | map(select(. != null)) | sort_by(.LastModified) | .[:-($files_to_keep | tonumber)][].Key')
    
    # Loop through each file to delete
    for file in $files_to_delete; do
        # Delete the file
        aws s3 rm "s3://${bucket_name}/${file}"
        echo "Deleted: ${file} in s3://${bucket_name}/${file}"
    done
done

refresh-available-snapshots-state
