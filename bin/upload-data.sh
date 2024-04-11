#!/usr/bin/env bash

################################################################################
# Script Name: upload_snapshot.sh
# Description: Uploads a snapshot to a specified location in an S3 bucket using
#              AWS CLI. The script assumes
# Parameters:
#   $1: Path to the file to upload.
#   $2: Entrypoint URL.
#   $3: Data source name.
#   $4: Bucket name.
#   $5: Network.
################################################################################

# Check if all parameters are provided
if [ $# -ne 5 ]; then
    echo "Usage: $0 <FILE_PATH> <ENTRYPOINT_URL> <BUCKET_NAME> <DATA_SOURCE_NAME> <NETWORK>"
    exit 1
fi

# Check if any parameter is null
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ]; then
    echo "Error: All parameters must be non-null."
    exit 1
fi

ENTRYPOINT_URL="$2"

# Define the bucket name and remote directory path
# Parameters: DATA_SOURCE_NAME, BUCKET_NAME, NETWORK
BUCKET_NAME="$3"
DATA_SOURCE_NAME="$4"
NETWORK="$5"
REMOTE_DIR_PATH="${BUCKET_NAME}/${DATA_SOURCE_NAME}/${NETWORK}"
REMOTE_PATH="s3://${REMOTE_DIR_PATH}/"

# Echo statement before listing buckets
echo "Listing contents of ${REMOTE_PATH} before operation:"
aws --endpoint-url="${ENTRYPOINT_URL}" s3 ls "${REMOTE_PATH}"

# Upload the snapshot to the specified path in S3
echo "Uploading $1 to ${REMOTE_PATH}."
aws --endpoint-url="${ENTRYPOINT_URL}" s3 cp "$1" "${REMOTE_PATH}"

# Echo statement after uploading (for debugging puropses)
echo "Listing contents of ${REMOTE_PATH} after operation:"
aws --endpoint-url="${ENTRYPOINT_URL}" s3 ls "${REMOTE_PATH}"
