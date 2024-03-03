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
MITHRIL_SNAPSHOTS_BASE_DIR="./mithril-snapshots"
# shellcheck disable=SC2034
KUPO_DATA="./kupo-data"
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
CONTAINER_DATA_DB_PATH="${CONTAINER_DATA_PATH}/db"
# shellcheck disable=SC2034
CONTAINER_KUPO_DB_PATH="/db"

# shellcheck disable=SC2034
LOCAL_CONFIG_PATH="./cardano-configurations/network"

# shellcheck disable=SC2034
EXPORTED_SNAPSHOT_BASE_PATH="exported-snapshots"

# shellcheck source=/dev/null
source "${MITHRIL_CONFIG}"

set_cardano_node_flag
