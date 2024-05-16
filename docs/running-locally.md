# Run cardanow locally (TODO outdatedw)
## Setup tooling
In order to work with the project scripts some tools are (some examples are `cardano-cli` and `mithril-client`). If you run nix, everything will be available in the nix flakes shell, these commands will enable a shell with all the tools that will be in this guide:
```bash
nix develop
```

If you are not a nix user, you will have to manually install the various tools:

**NOTE**: the versions of these tools are not yet bounded, the use case is still small enough that no version constrains are required yet, in the future che versions of at least the `mithril-client` and the `cardano-cli` will be specified.

## Run the project

In both cases, the project depend from a env variable `NETWORK` that identifies the cardano network that will be used for the flow.
The system is build in such a way that allows parallel execution on different `NETWORK`, the **Complete cycle** will show this.

### Individual steps
#### Setup
The system depends on different environment variables. If you are using `direnv` the variable are automatically loaded (with `NETWORK=preview`).

If you need to change the network (or you don't use `direnv`), you can run this:
```bash
NETWORK=preprod . bin/setup_env_vars.sh
```
#### Mithril snapshot download
The download of the mithril snapshot is currently done in `bin/download_with_mithril.sh`.

#### Snapshot exporter
The `cardano-ts` is a typescript component that takes the kupo generated database and compress it into the final artifact that will be uploaded
```shell
nix build .#cardanow-ts
```

The exporter will be available here: `./result/bin/cardanow-ts`

In order to run it, these variables must be set
`LOCAL_KUPO_DATA_PER_SNAPSHOT`: 
`EXPORTED_KUPO_SNAPSHOT_PATH`;

The kupo service must be running: the script will interact to it to check if kupo is synced.

To test the upload of the snapshot `EXPORTED_KUPO_SNAPSHOT_PATH` must be set.

## Run tests
If you use nix, tests will run during the check phase of the `cardano-ts` package.
