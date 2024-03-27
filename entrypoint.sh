#!/usr/bin/env bash

set -x
set -e
set -a

# Create directories "mithril-snapshot" and "kupo-data" if they don't exist
mkdir -p "${MITHRIL_SNAPSHOTS_BASE_DIR}" "${KUPO_DATA}" "${EXPORTED_SNAPSHOT_BASE_PATH}"

MITHRIL_QUERY=$(mithril-client cardano-db snapshot list --json | jq -r '.[0]')
# shellcheck disable=SC2034
DIGEST=$(jq -r '.digest' <<< "${MITHRIL_QUERY}")
SNAPSHOT_NAME=$(jq -r '.beacon | "\(.network)-\(.epoch)-\(.immutable_file_number)"' <<< "${MITHRIL_QUERY}")
# shellcheck disable=SC2034
LOCAL_MITHRIL_SNAPSHOT_DIR="${MITHRIL_SNAPSHOTS_BASE_DIR}/${SNAPSHOT_NAME}"

SNAPSHOT_DETAIL=$(mithril-client cardano-db snapshot show "${DIGEST}" --json)
CARDANO_NODE_VERSION=$(jq -r '.cardano_node_version' <<< "${SNAPSHOT_DETAIL}")

# shellcheck disable=SC2034
EXPORTED_KUPO_SNAPSHOT_PATH="${EXPORTED_SNAPSHOT_BASE_PATH}/kupo-${SNAPSHOT_NAME}.tgz"
LOCAL_KUPO_DATA_PER_SNAPSHOT="${KUPO_DATA}/${SNAPSHOT_NAME}"

echo "Aggregator endpoint: ${AGGREGATOR_ENDPOINT}"
echo "Genesis verification key: ${GENESIS_VERIFICATION_KEY}"

mithril-client -v cardano-db download "${DIGEST}" --download-dir "${LOCAL_MITHRIL_SNAPSHOT_DIR}"

echo "Last digest: ${DIGEST}"
echo "Store snapshot dir: ${LOCAL_MITHRIL_SNAPSHOT_DIR}"
echo "Local kupo data snapshot dir: ${LOCAL_KUPO_DATA_PER_SNAPSHOT}"

# TODO: this is currently not used: recent cardano-node images are not present in dockerhub
echo "Cardano node detail: ${CARDANO_NODE_VERSION}"

docker compose -p "${NETWORK}" up -d

cardanow-ts

docker compose -p "${NETWORK}" down

./upload.sh
