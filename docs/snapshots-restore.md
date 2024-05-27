# Restore snapshots

## Restore a Kupo snapshot

### Prerequisites

Kupo has some [requirements](https://cardanosolutions.github.io/kupo/#section/Getting-started) to start. The most straightforward approach is to download a snapshot of the Cardano ledger using Mithril and start a Cardano node from that. The Mithril client will print out the exact command to run to start the node.

Once the Cardano node is up and running, you can proceed with the restore of the Kupo snapshot.

### Restore the snapshot

To restore a Kupo snapshot, you can simply download one from [here](https://cardanow.staging.mlabs.city/available-snapshots.json). Extract it to a directory and use it as Kupo's `workdir` (as described [here](https://cardanosolutions.github.io/kupo/#section/Getting-started/-in-memory-workdir-dir)).
You can take a look at [examples](../examples) to see a very simple approach to restore the latest kupo snapshot for a given network.
