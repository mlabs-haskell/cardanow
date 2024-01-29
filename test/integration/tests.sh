#!/usr/bin/env bats

ROOT='.'

exit_if_empty() {
    local directory="$1"

    if [ -n "$(ls -A "$directory")" ]; then
        echo "Directory '$directory' is not empty"
    else
        echo "Directory '$directory' is empty"
        exit 1
    fi
}

@test "download-mithril-snapshot" {
    "${ROOT}/components/cardano-node/download-mithril-snapshot.sh"
    exit_if_empty "${ROOT}/mithril-snapshot/"
}
