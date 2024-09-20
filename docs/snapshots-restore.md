# Restoring Snapshots

## Prerequisites

To restore a snapshot, both **Kupo** and **Cardano DB Sync** require a running **Cardano Node**. The simplest way to set this up is by downloading a snapshot of the Cardano ledger using **Mithril** and starting a Cardano node from that. The Mithril client will provide the exact command to start the node.

Once the Cardano Node is up and running, you can proceed with restoring the snapshot.

To download a snapshot, visit [this link](https://cardanow.staging.mlabs.city/available-snapshots.json).

## Restoring a Kupo Snapshot

1. Extract the downloaded snapshot to a directory.
2. Use this directory as Kupo’s `workdir` (instructions are available [here](https://cardanosolutions.github.io/kupo/#section/Getting-started/-in-memory-workdir-dir)).

For a simple approach to restoring the latest Kupo snapshot for a given network, refer to the [examples](../examples).

## Restoring Cardano DB Sync Snapshot

The snapshot includes both the **PostgreSQL dump** and the **lstate** files required to resume synchronization.

For a straightforward example of how to restore the latest Kupo snapshot for a given network, refer to the [examples](../examples).
