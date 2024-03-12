#!/usr/bin/env sh
# FIXME (albertodvp 2024-02-12): env vars should bouble up to entrypoint script

if [ -z "${EXPORTED_KUPO_SNAPSHOT_PATH}" ]; then
    echo "EXPORTED_KUPO_SNAPSHOT_PATH is not set, exiting."
    exit 1
fi

# Define AWS credentials and default region
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-west-2


# Define the bucket name
BUCKET_NAME="kupo"
BUCKET_PATH="s3://${BUCKET_NAME}"
# Echo statement before listing buckets
echo "Listing buckets before operation:"
# List buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# Check if the bucket already exists
BUCKET_EXISTS=$(aws --endpoint-url=http://localhost:4566 s3 ls | grep -c "$BUCKET_NAME")

# If the bucket does not exist, create it
if [ "${BUCKET_EXISTS}" -eq 0 ]; then
    aws --endpoint-url=http://localhost:4566 s3 mb "${BUCKET_PATH}" 
    echo "Bucket $BUCKET_NAME created."
else
    echo "Bucket $BUCKET_NAME already exists."
fi

echo "Listing buckets after operation:"
aws --endpoint-url=http://localhost:4566 s3 ls

echo "Listing contents of $BUCKET_NAME before operation:"
aws --endpoint-url=http://localhost:4566 s3 ls "${BUCKET_PATH}"

echo "Uploading ${EXPORTED_KUPO_SNAPSHOT_PATH} to ${BUCKET_NAME}."
aws --endpoint-url=http://localhost:4566 s3 cp "${EXPORTED_KUPO_SNAPSHOT_PATH}" "${BUCKET_PATH}"
echo "${EXPORTED_KUPO_SNAPSHOT_PATH} uploaded to ${BUCKET_NAME}."

echo "Listing contents of ${BUCKET_NAME} after operation:"
aws --endpoint-url=http://localhost:4566 s3 ls "${BUCKET_PATH}"
