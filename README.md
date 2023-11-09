# Cardanow


The goal of this project is to reduce the friction Cardano developers encounter when trying to provision or maintain the necessary infrastructure for a DApp. 

The first step in this direction is to provide a caching service for three key components in almost any DApp: the cardano node, cardano-db-sync and kupo.


## Architecture

The goal of this system is to build snapshots for the three components listed above, and then upload them to some location where they will be retrievable by end users.

We can almost view this as a CI project, where we have to regularly build some artifact (the snapshot), and push it to some service where users can consume it (usually a registry, or some cloud storage).

As a goal, we want to make these builds as deterministic as possible, so each user always has the option to run this service themself and verify the authenticity of each snapshot.

As a starting point, we need to produce, or obtain, some trustable snapshots of the state of the cardano-node.
The [Mithril Network][1] has recently been established with this very goal, and currently produces several snapshots of the node db per epoch, across different networks (mainnet, preprod and preview).

We can focus our attention one one single network from now on: and assume that we will be running an instance of this system for each network we need to cover.

At the end of each epoch, we can fetch the latest snapshot for that epoch from the mithril network. This will be the state of the cardano-node that all of our other snapshots will be based on.

We will now provision a cardano-node using the mithril snapshot, but prevent it from receiving new blocks.
Once the node is ready, we can spin up instances of each indexer we want to build a snapshot for. These components will connect to the same cardano-node. Each build script will need a way to query the indexer and detect if it is done processing all the data from the node [example][2].

> As a note, the snapshots produced by cardano-db-sync are dependent on [the architecture][3]. TODO: So we will either have to pick a single architecture to build or provide a build matrix across all supported architectures.

Once this is done will have snapshots of the databases for all the supported indexers, alongside the snapshot of the cardano-node we fetched from the mithril network.

All these snapshots (TODO: also the cardano node one? Does it make sense to duplicate these since anyone can fetch them throuh mithril?) will then be packaged and pushed to some centralised storage (TODO: s3?).

## Using the cache

Scripts are provided for:

- Cardano-node
- Kupo
- cardano-db-sync

These are meant to download snapshots for each service and start the service with the snapshotted data

## Cardano node

Script to fetch data from S3, then script to launch docker image mounting that folder as DB in volume.

TODO: Alternative, skip uploading node snapshots to S3. Use something like https://github.com/blinklabs-io/docker-cardano-node to pre-bake mithril parameters and use mithril client to pull snapshot

## Kupo

Script to fetch data from S3. Here we can use `kupo copy` [4][4] to allow users to reduce their final DB. We will always export a copy of the DB that indexes *. Users can specify what kupo filters they want and we can restrict the DB to only those matches

## cardano-db-sync

Script to fetch data from S3. then use  `postgresql-setup.sh --restore-snapshot` to restore snapshot. cardano-db-sync can then be started pointing at the same DB


[1]: https://mithril.network/doc/
[2]: https://cardanosolutions.github.io/kupo/#operation/getHealth
[3]: https://github.com/input-output-hk/cardano-db-sync/blob/release/13.1.1.x/doc/state-snapshot.md#things-to-note
[4]: https://github.com/CardanoSolutions/kupo/blob/master/CHANGELOG.md#240---2023-02-23
