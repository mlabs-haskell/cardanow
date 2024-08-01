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

echo "Clone cardano-configurations"
rm -fr cardano-configurations
git clone https://github.com/input-output-hk/cardano-configurations.git
cd cardano-configurations || exit
# NOTE: this is simply the most recent commit in master
# if you update this hash, you should check the restore script works.
git checkout 6d7fac44d6a877ae9a3cf5eeda163ae539b17774 
cd .. || exit

echo "Setting up variables"
source bin/setup-env-vars.sh

echo "Downloading the latest cardano-node snapshot for ${NETWORK}"
source bin/download-with-mithril.sh

echo "Downloading the latest kupo snapshot for ${NETWORK}"
./bin/download-cardano-db-sync-latest.sh

# echo "Start cardano-node and kupo from downloaded snapshots"
# docker compose --project-directory . -f examples/cardano-db-sync/docker-compose.yaml up -d --force-recreate --build -p "${NETWORK}"
