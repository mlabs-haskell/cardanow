#!/usr/bin/env bash

set -x
set -a

# Create data directories if they don't exist
mkdir -p "${SNAPSHOTS_CARDANO_NODE_DIR}" "${SNAPSHOTS_KUPO_DIR}" "${EXPORTED_SNAPSHOT_BASE_PATH_WITH_DATA_SOURCE}"

MITHRIL_QUERY=$(mithril-client cardano-db snapshot list --json | jq -r '.[0]')
# shellcheck disable=SC2034
DIGEST=$(jq -r '.digest' <<< "${MITHRIL_QUERY}")
MITHRIL_SNAPSHOT_NAME=$(jq -r '.beacon | "\(.network)-\(.epoch)-\(.immutable_file_number)"' <<< "${MITHRIL_QUERY}")
# shellcheck disable=SC2034
LOCAL_CARDANO_NODE_SNAPSHOT_DIR="${SNAPSHOTS_CARDANO_NODE_DIR}/${MITHRIL_SNAPSHOT_NAME}"

SNAPSHOT_DETAIL=$(mithril-client cardano-db snapshot show "${DIGEST}" --json)
CARDANO_NODE_VERSION=$(jq -r '.cardano_node_version' <<< "${SNAPSHOT_DETAIL}")

# shellcheck disable=SC2034
EXPORTED_KUPO_SNAPSHOT_PATH="${EXPORTED_SNAPSHOT_BASE_PATH_WITH_DATA_SOURCE}/${DATA_SOURCE}-${MITHRIL_SNAPSHOT_NAME}.tgz"
LOCAL_KUPO_DATA_PER_SNAPSHOT="${SNAPSHOTS_KUPO_DIR}/${MITHRIL_SNAPSHOT_NAME}"

LOCAL_KUPO_SNAPSHOT_DIR="${SNAPSHOTS_KUPO_DIR}/${MITHRIL_SNAPSHOT_NAME}"

echo "Aggregator endpoint: ${AGGREGATOR_ENDPOINT}"
echo "Genesis verification key: ${GENESIS_VERIFICATION_KEY}"

echo "Deleting previous dir (if present): ${LOCAL_CARDANO_NODE_SNAPSHOT_DIR}"
# NOTE: we don't delete the folder it it's already present, the download with mithril-client will fail in that case
rm -fr "${LOCAL_CARDANO_NODE_SNAPSHOT_DIR}"
mithril-client -vvv cardano-db download "${DIGEST}" --download-dir "${LOCAL_CARDANO_NODE_SNAPSHOT_DIR}" || true

echo "Last digest: ${DIGEST}"
echo "Store snapshot dir: ${LOCAL_CARDANO_NODE_SNAPSHOT_DIR}"
echo "Local kupo data snapshot dir: ${LOCAL_KUPO_DATA_PER_SNAPSHOT}"
echo "Exported kupo snapshot path: ${EXPORTED_KUPO_SNAPSHOT_PATH}"
