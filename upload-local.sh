#!/usr/bin/env sh

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

echo "Uploading kupo.tgz to $BUCKET_NAME."
aws --endpoint-url=http://localhost:4566 s3 cp "${SNAPSHOT_PATH}" "${BUCKET_PATH}"
echo "kupo.tgz uploaded to $BUCKET_NAME."

echo "Listing contents of $BUCKET_NAME after operation:"
aws --endpoint-url=http://localhost:4566 s3 ls "${BUCKET_PATH}"
