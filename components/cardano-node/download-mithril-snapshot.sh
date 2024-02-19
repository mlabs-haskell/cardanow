#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# Get the absolute path of the directory containing the current script
# The cd command ensures that symbolic links are resolved to their real paths
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Calculate the path to the parent directory of the script
COMPONENT_DIR=$(realpath "${SCRIPT_DIR}/..")

# Calculate the path to the parent directory of the component directory
ROOT_DIR=$(realpath "${COMPONENT_DIR}/..")

MITHRIL_SNAPSHOTS="${ROOT_DIR}/${MITHRIL_SNAPSHOTS_BASE_DIR}/${NETWORK}"

# shellcheck source=/dev/null
source "${MITHRIL_CONFIG}"

mithril-client -vvv snapshot download latest --download-dir "${MITHRIL_SNAPSHOTS}"
