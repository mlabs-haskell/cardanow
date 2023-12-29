#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
COMPONENT_DIR="$SCRIPT_DIR/.."
ROOT_DIR="$COMPONENT_DIR/.."

# shellcheck source=/dev/null
source "${ROOT_DIR}/configurations/mithril-configs/${NETWORK}.env"

rm -rf "$ROOT_DIR/db"

mithril-client snapshot download latest

mv "$ROOT_DIR/db/*" "$ROOT_DIR/mithril-snapshot"
