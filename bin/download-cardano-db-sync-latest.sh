#!/usr/bin/env bash

# TODO this is very similar to the kupo script, we might want to make this dry

set -x

destination_path="${LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT}"

# Fetch the JSON file
json_url="https://pub-b887f41ffaa944ebaae543199d43421c.r2.dev/available-snapshots.json"
json_data=$(curl -s "$json_url")

# Extract the URL
most_recent_url=$(echo "$json_data" | jq -r --arg network "$NETWORK" '[.[] | select(.DataSource == "cardano-db-sync" and .Network == $network)] | sort_by(.Epoch) | sort_by(.ImmutableFileNumber) | .[-1].Key')

# Check if the URL is available
if [ "$most_recent_url" == "null"  ]; then
    echo "No URL found for the most recent kupo item in network $NETWORK."
    exit 1
fi

base_dir="${destination_path}"
mkdir -p "${base_dir}"
destination="${base_dir}/cardano_db_sync_latest.tgz"
# Download the tar.gz file and check if download was successful
echo "Downloading $most_recent_url..."
if ! curl "${most_recent_url}" -o "${destination}"; then
    echo "Failed to download $most_recent_url."
    exit 1
fi

# Extract the tar.gz file and check if extraction was successful
echo "Extracting $destination_path/cardano_db_sync_latest.tgz to $destination_path..."
if ! tar -xvf "${destination}" -C "${destination_path}"; then
    echo "Failed to extract $destination_path/cardano_db_sync_latest.tgz."
    exit 1
fi

# echo "Running postgres"
docker run -d \
  --name restore_postgres_container \
  -e PGPASSWORD="${PGPASSWORD}" \
  -e POSTGRES_PASSWORD="${PGPASSWORD}" \
  -e PGUSER="${PGUSER}" \
  -e PGDATABASE="${PGDATABASE}" \
  -v "${NETWORK}_postgres":/var/lib/postgresql/data \
  -v "${LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT}":/backup_data \
  -p 5432:5432 \
  postgres:14.10-alpine

# echo "Wait postresql is up"
# sleep 30s

echo "Running pg_restore"
docker exec restore_postgres_container \
  sh -c "createdb ${PGDATABASE}"

docker exec restore_postgres_container \
  sh -c 'pg_restore \
    --schema=public \
    --jobs=4 \
    --format=directory \
    --dbname="${PGDATABASE}" \
    --no-owner \
    --exit-on-error \
    "/backup_data"'

