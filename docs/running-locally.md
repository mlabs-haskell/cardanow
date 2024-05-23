# Run cardanow locally

## Setup tooling

In order to work with the project scripts some tools are (some examples are `cardano-cli` and `mithril-client`). If you run nix, everything will be available in the nix flakes shell, these commands will enable a shell with all the tools that will be in this guide:

```bash
nix develop
```

## Run the project

The project depend from a env variable `NETWORK` that identifies the cardano network that will be used for the flow.
The system is build in such a way that allows parallel execution on different `NETWORK`.

### Individual steps

#### Setup

The system depends on different environment variables. If you are using `direnv` the variable are automatically loaded (with `NETWORK=preview`).

If you need to change the network (or you don't use `direnv`), you can run this:

```bash
NETWORK=preprod . bin/setup_env_vars.sh
```

#### Mithril snapshot download

The download of the mithril snapshot is currently done in `bin/download-with-mithril.sh`.

#### Snapshot exporter

The `cardano-ts` is a typescript component that takes the kupo generated database and compress it into the final artifact that will be uploaded

```shell
nix build .#cardanow-ts
```

nix run .\#cardanow-preview
The exporter will be available here: `./result/bin/cardanow-ts`

In order to run it, these variables must be set
`LOCAL_KUPO_DATA_PER_SNAPSHOT`:
`EXPORTED_KUPO_SNAPSHOT_PATH`;

The kupo service must be running: the script will interact to it to check if kupo is synced.

To test the upload of the snapshot `EXPORTED_KUPO_SNAPSHOT_PATH` must be set.

### Run everything

To run the exported for a selected network you can simply run:

```shell
nix run .#cardanow-preview
nix run .#cardanow-preprod
nix run .#cardanow-mainnet
```

## Run tests

Tests will run during the check phase of the `cardano-ts` package.
