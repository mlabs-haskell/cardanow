#!/usr/bin/env bash

export NETWORK="preprod"

echo "Setting up variables"
source bin/setup-env-vars.sh

echo "Downloading the latest cardano-node snapshot for ${NETWORK}"
source bin/download-with-mithril.sh

echo "Downloading the latest kupo snapshot for ${NETWORK}"
source bin/download-kupo-latest.sh

