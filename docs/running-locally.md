# Run cardanow locally
## Setup tooling
In order to work with the project scripts some tools are (some examples are `cardano-cli` and `mithril-client`). If you run nix, everything will be available in the nix flakes shell, these commands will enable a shell with all the tools that will be in this guide:
```
git submodule update --init --recursive
nix develop
```

If you are not a nix user, you will have to manually install the various tools:
- docker
- docker-compose
- cardano-cli
- mithril-client-cli
- jq
- nodejs
- nixos-rebuild

**NOTE**: the versions of these tools are not yet bounded, the use case is still small enough that no version constrains are required yet, in the future che versions of at least the `mithril-client` and the `cardano-cli` will be specified.

## Install nodejs dependencies
You will need to install the node dependencies. You only need this step once

```shell
npm i
```

## Download Mithril snapshot
Use the `download-mithril-snapshot.sh` script to download the snapshot. You will need to specify a `NETWORK` env var

```shell
NETWORK=preview ./components/cardano-node/download-mithril-snapshot.sh
```

## Build environment - isolated network
Start the compose environment. You will need to specify a `NETWORK` env var:
```shell
NETWORK=preview
MITHRIL_CONFIG=configurations/mithril-configs/$NETWORK.env
docker compose --env-file $MITHRIL_CONFIG up -d
```

To verify the cardano node is actually running you can run:
```shell
docker compose run cardano-node cli "query tip --testnet-magic 2 --socket-path /ipc/node.socket"
```

**NOTE**: if you want to try query tip check for other networks (preprod/mainnet), you have to update the argument `(--testnet NATURAL|--mainnet)` flag.

## Run tests
To run the tests:
```shell
npm test
```

## Run the exporter
To run the tests:
```shell
nix run .#cardanow
```
This command will export the snapshot of kupo into a compressed tar.
NOTE: the containers spawned by the `compose up` must be running correctly to successfully complete the export.
