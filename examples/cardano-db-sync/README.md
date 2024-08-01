# Examples

This section of the repository contains some utilities to demonstrate how the service can be used.

## Restore cardano-db-sync Snapshot

A simple and demonstrative approach to restore the latest cardano-db-sync snapshot (from the `preprod` network) is by using the following script:

Note: the password can be changed but it's not particularly relevant for the example.
```bash
PGPASSWORD="not-really-relevant" ./examples/cardano-db-sync/start-restore.sh preprod
```

This script is solely for demonstration purposes. If you are interested in using the snapshot produced by Cardanow, you may want to implement your own script to fetch the snapshot from [the exported snapshots file](https://cardanow.staging.mlabs.city/available-snapshots.json).
