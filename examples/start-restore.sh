#!/usr/bin/env bash

# Check if the first argument is provided, otherwise exit with an error message
if [ -z "$1" ]; then
  echo "Error: NETWORK variable not provided."
  echo "Usage: $0 <network>"
  exit 1
fi

# Assign the first argument to the NETWORK variable
NETWORK=$1

# Export the NETWORK variable
export NETWORK

echo "Setting up variables"
source bin/setup-env-vars.sh

echo "Downloading the latest cardano-node snapshot for ${NETWORK}"
source bin/download-with-mithril.sh
.shellcheckrc
echo "Downloading the latest kupo snapshot for ${NETWORK}"
./bin/download-kupo-latest.sh

env

echo "Start cardano-node and kupo from downloaded snapshots"
docker compose --project-directory . -f examples/docker-compose.yaml up -d --force-recreate --build
