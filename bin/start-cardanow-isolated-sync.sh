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

docker compose -p "${NETWORK}" up -d

echo "Starting cardanow-ts"

cardanow-ts

docker compose -p "${NETWORK}" down
