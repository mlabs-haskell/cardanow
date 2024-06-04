#!/usr/bin/env bash

set -x

destination_path="${LOCAL_KUPO_DATA_PER_SNAPSHOT}"

# Fetch the JSON file
json_url="https://pub-b887f41ffaa944ebaae543199d43421c.r2.dev/available-snapshots.json"
json_data=$(curl -s "$json_url")

# Extract the URL
most_recent_url=$(echo "$json_data" | jq -r --arg network "$NETWORK" '[.[] | select(.DataSource == "kupo" and .Network == $network)] | sort_by(.Epoch) | sort_by(.ImmutableFileNumber) | .[-1].Key')

# Check if the URL is available
if [ "$most_recent_url" == "null"  ]; then
    echo "No URL found for the most recent kupo item in network $NETWORK."
    exit 1
fi

base_dir="${destination_path}"
mkdir -p "${base_dir}"
destination="${base_dir}/kupo_latest.tgz"
# Download the tar.gz file and check if download was successful
echo "Downloading $most_recent_url..."
if ! curl "${most_recent_url}" -o "${destination}"; then
    echo "Failed to download $most_recent_url."
    exit 1
fi

# Extract the tar.gz file and check if extraction was successful
echo "Extracting $destination_path/kupo_latest.tgz to $destination_path..."
if ! tar -xvf "${destination}" -C "${destination_path}"; then
    echo "Failed to extract $destination_path/kupo_latest.tgz."
    exit 1
fi

echo "Kupo has been successfully fetched and extracted to $destination_path."
