#!/usr/bin/env bash

set -x
set -a

# Create data directories if they don't exist
mkdir -p "${SNAPSHOTS_CARDANO_NODE_DIR}" "${SNAPSHOTS_KUPO_DIR}" "${SNAPSHOTS_KUPO_DIR}" "${EXPORTED_SNAPSHOT_BASE_PATH_WITH_DATA_SOURCE_KUPO}" "${EXPORTED_SNAPSHOT_BASE_PATH_WITH_DATA_SOURCE_CARDANO_DB_SYNC}"

MITHRIL_QUERY=$(mithril-client cardano-db snapshot list --json | jq -r '.[0]')
# shellcheck disable=SC2034
DIGEST=$(jq -r '.digest' <<< "${MITHRIL_QUERY}")
MITHRIL_SNAPSHOT_NAME=$(jq -r '.beacon | "\(.network)-\(.epoch)-\(.immutable_file_number)"' <<< "${MITHRIL_QUERY}")
# shellcheck disable=SC2034
LOCAL_CARDANO_NODE_SNAPSHOT_DIR="${SNAPSHOTS_CARDANO_NODE_DIR}/${MITHRIL_SNAPSHOT_NAME}"

# SNAPSHOT_DETAIL=$(mithril-client cardano-db snapshot show "${DIGEST}" --json)
# CARDANO_NODE_VERSION=$(jq -r '.cardano_node_version' <<< "${SNAPSHOT_DETAIL}")

# shellcheck disable=SC2034
EXPORTED_KUPO_SNAPSHOT_PATH="${EXPORTED_SNAPSHOT_BASE_PATH_WITH_DATA_SOURCE_KUPO}/kupo-${MITHRIL_SNAPSHOT_NAME}.tgz"
# shellcheck disable=SC2034
EXPORTED_CARDANO_DB_SYNC_SNAPSHOT_PATH="${EXPORTED_SNAPSHOT_BASE_PATH_WITH_DATA_SOURCE_CARDANO_DB_SYNC}/cardano-db-sync-${MITHRIL_SNAPSHOT_NAME}.tgz"
# shellcheck disable=SC2034
LOCAL_KUPO_DATA_PER_SNAPSHOT="${SNAPSHOTS_KUPO_DIR}/${MITHRIL_SNAPSHOT_NAME}"
# shellcheck disable=SC2034
LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT="${SNAPSHOTS_CARADNO_DB_SYNC_DIR}/${MITHRIL_SNAPSHOT_NAME}"

# shellcheck disable=SC2034
EPOCH=$(jq -r '.beacon | "\(.epoch)"' <<< "${MITHRIL_QUERY}")

echo "Aggregator endpoint: ${AGGREGATOR_ENDPOINT}"
echo "Genesis verification key: ${GENESIS_VERIFICATION_KEY}"

if [ ! -d "${LOCAL_CARDANO_NODE_SNAPSHOT_DIR}" ]; then
  mkdir -p "${LOCAL_CARDANO_NODE_SNAPSHOT_DIR}"
  mithril-client cardano-db download "${DIGEST}" --download-dir "${LOCAL_CARDANO_NODE_SNAPSHOT_DIR}" || true
else
  echo "Directory ${LOCAL_CARDANO_NODE_SNAPSHOT_DIR} already exists. Skipping download."
fi


echo "Last digest: ${DIGEST}"
echo "Store snapshot dir: ${LOCAL_CARDANO_NODE_SNAPSHOT_DIR}"
echo "Local kupo data snapshot dir: ${LOCAL_KUPO_DATA_PER_SNAPSHOT}"
echo "Local cardano-db-sync data snapshot dir: ${LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT}"
echo "Exported kupo snapshot path: ${EXPORTED_KUPO_SNAPSHOT_PATH}"
echo "Exported cardano-db-sync snapshot path: ${EXPORTED_CARDANO_DB_SYNC_SNAPSHOT_PATH}"
echo "Epoch: ${EPOCH}"

