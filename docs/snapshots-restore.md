# Restore snapshots

We have created a docker image that contains the cardano-node together with a mithril-client. This image can be used to restore the latest snapshot for each network before starting the node. This image is automatically built and pushed to dockerhub every time there is an update to the relevant files on the repo provide several ways of using the snapshots for the supported components.

## Restore a kupo snapshot

### Download the snapshot

To restore a kupo snapshot, you first have to download a snapshot from the `cardanow` service (say `snapshot.tar.gz`).

### Run cupo

You can now start kupo
