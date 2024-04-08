#!/usr/bin/env sh

# FIXME (albertodvp 2024-02-12): env vars should bubble up to entrypoint script
set -x
# TODO rename this
if [ -z "${EXPORTED_KUPO_SNAPSHOT_PATH}" ]; then
    echo "EXPORTED_KUPO_SNAPSHOT_PATH is not set, exiting."
    exit 1
fi

# Define AWS credentials and default region
export AWS_DEFAULT_REGION=auto
export ENTRYPOINT_URL=https://5c90369860b916812808cd543a1d782b.r2.cloudflarestorage.com

# Define the bucket name
# TODO this should be a parameter
DATA_SOURCE_NAME="kupo"
BUCKET_NAME="cardanow"
REMOTE_DIR_PATH="${BUCKET_NAME}/${DATA_SOURCE_NAME}/${NETWORK}"
REMOTE_PATH="s3://${REMOTE_DIR_PATH}/"
# Echo statement before listing buckets
echo "Listing contents of ${REMOTE_PATH} before operation:"
aws --endpoint-url="${ENTRYPOINT_URL}" s3 ls "${REMOTE_PATH}"

echo "Uploading ${EXPORTED_KUPO_SNAPSHOT_PATH} to ${REMOTE_PATH}."
aws --endpoint-url="${ENTRYPOINT_URL}" s3 cp "${EXPORTED_KUPO_SNAPSHOT_PATH}" "${REMOTE_PATH}"

echo "Listing contents of ${REMOTE_PATH} after operation:"
aws --endpoint-url="${ENTRYPOINT_URL}" s3 ls "${REMOTE_PATH}"
