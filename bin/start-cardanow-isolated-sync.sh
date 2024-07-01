#!/usr/bin/env bash

set -x
set -a

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

cardanow-ts

echo "Stopping cardanow isoldated containers"

docker compose -p "${NETWORK}" down

echo "Cleaning up data"

rm -fr "${LOCAL_KUPO_DATA_PER_SNAPSHOT}" "${LOCAL_CARDANO_NODE_SNAPSHOT_DIR}"
