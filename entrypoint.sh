#!/usr/bin/env bash

source ./setup_env_vars.sh

set -x
set -e
set -a


# Check if the last directory in the current path is "cardanow"
# This allows to use the same script both in local (where the dir is there) and remote host where we might have to clone the 
if [[ $(basename "${PWD}") != "cardanow" ]]; then
    # FIXME (albertodvp 2024-02-09): lock the version here
    echo "Cloning cardanow"
    git clone git@github.com:mlabs-haskell/cardanow.git
    cd cardanow || exit 1 
fi

# Create directories "mithril-snapshot" and "kupo-data" if they don't exist
mkdir -p "${MITHRIL_SNAPSHOTS_BASE_DIR}" "${KUPO_DATA}"

MITHRIL_QUERY=$(mithril-client snapshot list --json | jq -r '.[0]')
DIGEST=$(jq -r '.digest' <<< "${MITHRIL_QUERY}")
SNAPSHOT_NAME=$(jq -r '.beacon | "\(.network)-\(.epoch)-\(.immutable_file_number)"' <<< "${MITHRIL_QUERY}")
MITHRIL_SNAPSHOT_DIR="${MITHRIL_SNAPSHOTS_BASE_DIR}/${SNAPSHOT_NAME}"
EXPORTED_SNAPSHOT_BASE_PATH="exported-snapshots"
# shellcheck disable=SC2034
EXPORTED_KUPO_SNAPSHOT_PATH="${EXPORTED_SNAPSHOT_BASE_PATH}/kupo-${SNAPSHOT_NAME}.tgz"


mithril-client -vvv snapshot download latest --download-dir "${MITHRIL_SNAPSHOT_DIR}" || DOWNLOAD_SUCCEEDED=$?

if [ "${DOWNLOAD_SUCCEEDED}" -eq 0 ]; then
    echo "Download succeeded"
else
    echo "Download failed, maybe the snapshot is already in the filesystem"
fi

echo "Last digest: ${DIGEST}"
echo "Store snapshot dir: ${MITHRIL_SNAPSHOT_DIR}"

docker compose up -d

# docker compose run cardano-node cli "query tip ${CARDANO_NODE_FLAG} --socket-path ${CONTAINER_SOCKET_PATH}"

# nix run .#cardanow-ts

# docker compose down

# docker compose -f docker-compose-localstack.yaml up -d

# ./upload-local.sh

# docker compose -f docker-compose-localstack.yaml up -d

