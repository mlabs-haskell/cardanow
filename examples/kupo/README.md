# Examples

This section of the repository contains some utilities to demonstrate how the service can be used.

## Restore Kupo Snapshot

A simple and demonstrative approach to restore the latest Kupo snapshot (from the `preprod` network) is by using the following script:

```bash
./examples/kupo/start-restore.sh preprod
```

This script is solely for demonstration purposes. If you are interested in using the snapshot produced by Cardanow, you may want to implement your own script to fetch the snapshot from [the exported snapshots file](https://cardanow.staging.mlabs.city/available-snapshots.json).
