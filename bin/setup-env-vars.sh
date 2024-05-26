#!/usr/bin/env bash

set -a

# Define the function to set CARDANO_NODE_FLAG
set_cardano_node_flag() {
    case "${NETWORK}" in
        "preview")
            CARDANO_NODE_FLAG="--testnet-magic 2"
            KUPO_PORT=1442
            ;;
        "preprod")
            CARDANO_NODE_FLAG="--testnet-magic 1"
            KUPO_PORT=1443

            ;;
        "mainnet")
            # shellcheck disable=SC2034
            CARDANO_NODE_FLAG="--mainnet"
            # shellcheck disable=SC2034
            KUPO_PORT=1444
            ;;
        *)
            echo "Unknown network: $NETWORK"
            exit 1
            ;;
    esac
}
# shellcheck disable=SC2034
SNAPSHOTS_BASE_DIR="./snapshots/${NETWORK}"
# shellcheck disable=SC2034
SNAPSHOTS_CARDANO_NODE_DIR="${SNAPSHOTS_BASE_DIR}/cardano-node"
# shellcheck disable=SC2034
SNAPSHOTS_KUPO_DIR="${SNAPSHOTS_BASE_DIR}/kupo"
# shellcheck disable=SC2034
MITHRIL_CONFIG="./mithril-configurations/${NETWORK}.env"
CONTAINER_IPC_PATH="/ipc"
# shellcheck disable=SC2034
CONTAINER_SOCKET_PATH="${CONTAINER_IPC_PATH}/${NETWORK}.socket"
CONTAINER_CONFIG_BASE_PATH="/config"
CONTAINER_CONFIG_PATH="${CONTAINER_CONFIG_BASE_PATH}/${NETWORK}/cardano-node"
# shellcheck disable=SC2034
CONTAINER_CONFIG_CONFIG_PATH="${CONTAINER_CONFIG_PATH}/config.json"
# shellcheck disable=SC2034
CONTAINER_CONFIG_TOPOLOGY_PATH="${CONTAINER_CONFIG_PATH}/topology.json"
# shellcheck disable=SC2034
CONTAINER_DATA_PATH="/data"
# shellcheck disable=SC2034
CONTAINER_DATA_CARDANO_NODE_PATH="${CONTAINER_DATA_PATH}"
# shellcheck disable=SC2034
CONTAINER_DATA_KUPO_PATH="${CONTAINER_DATA_PATH}/kupo"

# shellcheck disable=SC2034
LOCAL_CONFIG_PATH="./cardano-configurations/network"
# shellcheck disable=SC2034
LOCAL_NONIX_CONFIG_PATH="./config/cardano-configurations/network"

# shellcheck disable=SC2034
EXPORTED_SNAPSHOT_BASE_PATH="./exported-snapshots"

# TODO make this temporary
# shellcheck disable=SC2034
DATA_SOURCE="kupo"

# shellcheck disable=SC2034
EXPORTED_SNAPSHOT_BASE_PATH_WITH_DATA_SOURCE="${EXPORTED_SNAPSHOT_BASE_PATH}/${NETWORK}/${DATA_SOURCE}"

# shellcheck disable=SC2034
BUCKET_NAME="cardanow"

# shellcheck disable=SC2034
AWS_DEFAULT_REGION=auto
# shellcheck disable=SC2034
AWS_ENDPOINT_URL="https://5c90369860b916812808cd543a1d782b.r2.cloudflarestorage.com"

# shellcheck source=/dev/null
source "${MITHRIL_CONFIG}"

set_cardano_node_flag
