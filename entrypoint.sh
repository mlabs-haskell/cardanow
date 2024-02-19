#!/usr/bin/env bash

# This allows to use the same script both in local (where the dir is there) and remote host where we might have to clone the 
if [[ $(basename "${PWD}") != "cardanow" ]]; then
    # FIXME (albertodvp 2024-02-09): lock the version here
    echo "Cloning cardanow"
    git clone https://github.com/mlabs-haskell/cardanow.git

    cd cardanow || exit 1
fi

# shellcheck source=/dev/null
source setup_env_vars.sh

set -x
set -e
set -a


# Check if the last directory in the current path is "cardanow"

# Create directories "mithril-snapshot" and "kupo-data" if they don't exist
mkdir -p "${MITHRIL_SNAPSHOTS_BASE_DIR}" "${KUPO_DATA}" "${EXPORTED_SNAPSHOT_BASE_PATH}"

MITHRIL_QUERY=$(mithril-client snapshot list --json | jq -r '.[0]')
# shellcheck disable=SC2034
DIGEST=$(jq -r '.digest' <<< "${MITHRIL_QUERY}")
SNAPSHOT_NAME=$(jq -r '.beacon | "\(.network)-\(.epoch)-\(.immutable_file_number)"' <<< "${MITHRIL_QUERY}")
# shellcheck disable=SC2034
LOCAL_MITHRIL_SNAPSHOT_DIR="${MITHRIL_SNAPSHOTS_BASE_DIR}/${SNAPSHOT_NAME}"

# shellcheck disable=SC2034
EXPORTED_KUPO_SNAPSHOT_PATH="${EXPORTED_SNAPSHOT_BASE_PATH}/kupo-${SNAPSHOT_NAME}.tgz"
LOCAL_KUPO_DATA_PER_SNAPSHOT="${KUPO_DATA}/${SNAPSHOT_NAME}"

mithril-client -vvv snapshot download latest --download-dir "${LOCAL_MITHRIL_SNAPSHOT_DIR}" || DOWNLOAD_SUCCEEDED=$?

if [ "${DOWNLOAD_SUCCEEDED}" -eq 0 ]; then
    echo "Download succeeded"
else
    echo "Download failed, maybe the snapshot is already in the filesystem"
fi

echo "Last digest: ${DIGEST}"
echo "Store snapshot dir: ${LOCAL_MITHRIL_SNAPSHOT_DIR}"
echo "Local kupo data snapshot dir: ${LOCAL_KUPO_DATA_PER_SNAPSHOT}"

docker compose -p "${NETWORK}" up -d

# TODO use path in store (how do I get it)
nix run .#cardanow-ts

docker compose -p "${NETWORK}" down

docker compose -f docker-compose-localstack.yaml up -d

./upload-local.sh

