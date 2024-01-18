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

# shellcheck source=/dev/null
source "${ROOT_DIR}/configurations/mithril-configs/${NETWORK}.env"

rm -rf "${ROOT_DIR}/db"

mithril-client snapshot download latest

mv "${ROOT_DIR}/db/*" "${ROOT_DIR}/mithril-snapshot/" 
