# Snapshots Export

We currently use `aws s3 sync` to upload exported snapshots to the cloud bucket. This solution allows robust file uploads and decouples snapshot creation from snapshot upload.

Another advantage of this approach is that cleaning up older snapshots is easier: keeping the local folder updated is sufficient, as `aws s3 sync` will delete older snapshots from the remote environment as well.

## Cleaning Up Local Data

We provide a simple script to delete folders prone to size growth. This script must be executed manually:

```bash
nix run .#cleanup-local-data 3 exported-snapshots/{preview,preprod,mainnet} snapshots/{preview,preprod,mainnet}/{kupo,cardano-node}
```
