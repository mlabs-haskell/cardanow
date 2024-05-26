#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <CARDANO_NODE_FLAG> <CONTAINER_SOCKET_PATH>"
  exit 1
fi

# Assign arguments to variables
CARDANO_NODE_FLAG=$1
CONTAINER_SOCKET_PATH=$2

# Run the cardano-cli query tip command and capture the output
output=$(/usr/local/bin/cardano-cli query tip "${CARDANO_NODE_FLAG}" --socket-path "${CONTAINER_SOCKET_PATH}")

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
