#!/bin/sh

apk update
apk add curl jq
export NETWORK="preprod"
source bin/setup-env-vars.sh
source bin/download-with-mithril.sh
/app/download-kupo-latest.sh
