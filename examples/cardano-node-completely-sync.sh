#!/bin/bash

# Check if the correct number of arguments are provided
# Check if the required environment variables are set
if [ -z "$CARDANO_NODE_FLAG" ] || [ -z "$CONTAINER_SOCKET_PATH" ]; then
  echo "Error: Environment variables CARDANO_NODE_FLAG and CONTAINER_SOCKET_PATH must be set."
  exit 1
fi

# Run the cardano-cli query tip command and capture the output
# NOTE: we disable this rule here because CARDANO_NODE_FLAG can be "--testnet-magic NUMBER" and we don't
# want to pass that as a single string
# shellcheck disable=SC2086
output=$(/usr/local/bin/cardano-cli query tip ${CARDANO_NODE_FLAG} --socket-path "${CONTAINER_SOCKET_PATH}")

# Extract the syncProgress value using parameter expansion
sync_progress=$(echo "$output" | while read -r line; do
  if [[ "$line" == *'"syncProgress":'* ]]; then
    echo "$line" | cut -d '"' -f 4
  fi
done)

# Check if the syncProgress is 100.00
if [ "${sync_progress}" == "100.00" ]; then
  exit 0
else
  exit 1
fi
