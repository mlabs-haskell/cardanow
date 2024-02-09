#!/usr/bin/env bash

set -x
set -e
set -a

# Define the function to set CARDANO_NODE_FLAG
set_cardano_node_flag() {
    case "${NETWORK}" in
        "preview")
            CARDANO_NODE_FLAG="--testnet-magic 2"
            ;;
        "preprod")
            CARDANO_NODE_FLAG="--testnet-magic 1"
            ;;
        "mainnet")
            CARDANO_NODE_FLAG="--mainnet"
            ;;
        *)
            echo "Unknown network: $NETWORK"
            exit 1
            ;;
    esac
}
# Fixme (albertodvp 2024-09-02)

MITHRIL_SNAPSHOTS_BASE_DIR="mithril-snapshots"
KUPO_DATA="kupo-data"
MITHRIL_CONFIG="configurations/mithril-configs/${NETWORK}.env"
MITHRIL_SNAPSHOTS="${MITHRIL_SNAPSHOTS_BASE_DIR}"
CONTAINER_IPC_PATH="/ipc"
CONTAINER_SOCKET_PATH="${CONTAINER_IPC_PATH}/${NETWORK}.socket"
CONTAINER_CONFIG_BASE_PATH="/config"
CONTAINER_CONFIG_PATH="${CONTAINER_CONFIG_BASE_PATH}/${NETWORK}/cardano-node"
# shellcheck disable=SC2034
CONTAINER_CONFIG_CONFIG_PATH="${CONTAINER_CONFIG_PATH}/config.json"
# shellcheck disable=SC2034
CONTAINER_CONFIG_TOPOLOGY_PATH="${CONTAINER_CONFIG_PATH}/topology.json"
# shellcheck disable=SC2034
CONTAINER_DATA_PATH="/data/db"
# shellcheck disable=SC2034
LOCAL_CONFIG_PATH="/configurations/cardano-configurations/network"

# shellcheck source=/dev/null
source "${MITHRIL_CONFIG}"
set_cardano_node_flag
# Check if the last directory in the current path is "cardanow"
# This allows to use the same script both in local (where the dir is there) and remote host where we might have to clone the 
if [[ $(basename "${PWD}") != "cardanow" ]]; then
    # FIXME (albertodvp 2024-02-09): lock the version here
    echo "Cloning cardanow"
    git clone git@github.com:mlabs-haskell/cardanow.git
    cd cardanow || exit 1 
fi

# Create directories "mithril-snapshot" and "kupo-data" if they don't exist
mkdir -p "${MITHRIL_SNAPSHOTS}" "${KUPO_DATA}"

MITHRIL_QUERY=$(mithril-client snapshot list --json | jq -r '.[0]')
DIGEST=$(jq -r '.digest' <<< "${MITHRIL_QUERY}")
SNAPSHOT_NAME=$(jq -r '.beacon | "\(.network)-\(.epoch)-\(.immutable_file_number)"' <<< "${MITHRIL_QUERY}")
MITHRIL_SNAPSHOT="${MITHRIL_SNAPSHOTS}/${SNAPSHOT_NAME}"
EXPORTED_SNAPSHOT_BASE_PATH="exported-snapshots"
# shellcheck disable=SC2034
EXPORTED_KUPO_SNAPSHOT_PATH="${EXPORTED_SNAPSHOT_BASE_PATH}/kupo-${SNAPSHOT_NAME}.tgz"


mithril-client -vvv snapshot download latest --download-dir "${MITHRIL_SNAPSHOT}" || DOWNLOAD_SUCCEEDED=$?

if [ "${DOWNLOAD_SUCCEEDED}" -eq 0 ]; then
    echo "Download succeeded"
else
    echo "Download failed, maybe the snapshot is already in the filesystem"
fi

echo "Last digest: ${DIGEST}"
echo "Store snapshot dir: ${MITHRIL_SNAPSHOT}"
docker compose up -d

docker compose run cardano-node cli "query tip ${CARDANO_NODE_FLAG} --socket-path ${CONTAINER_SOCKET_PATH}"

nix run .#cardanow-ts

# docker compose down

# docker compose -f docker-compose-localstack.yaml up -d

# ./upload-local.sh

# docker compose -f docker-compose-localstack.yaml up -d

