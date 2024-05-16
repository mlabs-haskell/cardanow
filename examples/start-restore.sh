#!/usr/bin/env bash

export NETWORK="preprod"
# TODO ADD NOTE ABOUT MITRHIL CLIENT VERSION

echo "Setting up variables"
source bin/setup-env-vars.sh

echo "Downloading the latest cardano-node snapshot for ${NETWORK}"
source bin/download-with-mithril.sh

docker compose --project-directory . -f examples/docker-compose.yaml up -d
