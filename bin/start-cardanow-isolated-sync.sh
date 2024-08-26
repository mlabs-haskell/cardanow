#!/usr/bin/env bash

set -x
set -a

# shellcheck source=/dev/null
source bin/utils.sh


# Kill hanging containers
HANGING_CONTAINER=$(docker ps -aq -f name="${NETWORK}")
# Check if HANGING_CONTAINER is non-empty
if [ -n "$HANGING_CONTAINER" ]; then
    # Remove hanging containers
    echo "Removing hanging containers..."
    docker rm -f "${HANGING_CONTAINER}"
else
    echo "No hanging containers found."
fi

echo "Starting cardanow isoldated containers"

docker compose -p "${NETWORK}" up -d

echo "Starting cardanow-ts"

push_metric_to_prometheus "cardanowts_starts"

cardanow-ts

echo "Stopping cardanow isoldated containers"

docker compose -p "${NETWORK}" down

push_metric_to_prometheus "cardanowts_finished"


echo "Cleaning up data"

# Cleaning up

# Check if both required variables are set
if [ -z "$LOCAL_KUPO_DATA_PER_SNAPSHOT" ] || [ -z "$LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT" ]; then
  echo "Error: Required environment variables are not set" >&2
  exit 1
fi


# Run the docker command if variables are set
docker run -v ./snapshots:/snapshots \
  -e LOCAL_KUPO_DATA_PER_SNAPSHOT="${LOCAL_KUPO_DATA_PER_SNAPSHOT}" \
  -e LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT="${LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT}" \
  alpine sh -c 'rm -fr "/${LOCAL_KUPO_DATA_PER_SNAPSHOT}" "/${LOCAL_CARDANO_SYNC_DATA_DB_PER_SNAPSHOT}"'
