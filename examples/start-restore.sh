#!/usr/bin/env bash

export NETWORK="preprod"

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
