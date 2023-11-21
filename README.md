# Cardanow


The goal of this project is to reduce the friction Cardano developers encounter when trying to provision or maintain the necessary infrastructure for a DApp. 

The first step in this direction is to provide a caching service for three key components in almost any DApp: the cardano node, cardano-db-sync and kupo.

Check out [this video](https://www.youtube.com/watch?v=xuwEbPUlZ-s) for a high-level explanation of the architecture.


## Architecture

The goal of this system is to build snapshots for the three components listed above, and then upload them to some location where they will be retrievable by end users.

We can almost view this as a CI project, where we have to regularly build some artifact (the snapshot), and push it to some service where users can consume it (usually a registry, or some cloud storage).

As a goal, we want to make these builds as deterministic as possible, so each user always has the option to run this service themself and verify the authenticity of each snapshot.

As a starting point, we need to produce, or obtain, some trustable snapshots of the state of the cardano-node.
The [Mithril Network][1] has recently been established with this very goal, and currently produces several snapshots of the node db per epoch, across different networks (mainnet, preprod and preview).

We can focus our attention on one single network from now on: and assume that we will be running an instance of this system for each network we need to cover.

The following diagram shows the different components involved in producing these snapshots.

We will have a component called `Builder`, which represents some machine that will periodically be spun up to run this build

![Arch](./docs/cardanow.jpg)

At the end of each epoch, we can fetch the latest snapshot for that epoch through the Mithril network. This will be the state of the cardano-node that all of our other snapshots will be based on.

We will now provision a cardano-node using the snapshot, this node and all the indexers will be provisioned on a network with no outbound access, this means components have no connection to the internet, thus the node can not receive any other blocks than the ones in the mithril snapshot.

Once the node is ready, we can spin up instances of each indexer we want to build a snapshot for. These components will all connect to the same cardano-node.

Once this is done will have snapshots of the databases for all the supported indexers, alongside the snapshot of the cardano-node we fetched from the Mithril network.

All the generated snapshots can finally be uploaded back to our cache servers. To be able to fully identify each snapshot, we have to keep around some metadata about how it was generated. In particular, for each indexer snapshot, we will record:

- cardano-node version
- cardano-node snapshot
- indexer version

This information will be stored in the filename, for example assuming we produced a snapshot with `kupo v2.8.0` from a `cardano node v2.3.0` with the snapshot from `2023-10-10`, then this will be have a name like: `snapshot-kupo-2.8.0-2023-10-10-2.3.0.tar`.

We also have to account for the fact of periodically having to update versions of the node and indexers. Sometimes this will also mean that snapshots that were produced with an earlier version of the indexer, will not work with a later version of it.
We will attempt to always use the latest (major) cardano-node version to build the snapshots and - for each indexer - the latest (major) version supporting the node we are running.

### Notes

- The build script for each indexer will need a way to query the indexer and detect if it is done processing all the data from the node [example][2].

- Snapshots produced by cardano-db-sync are dependent on [the architecture][3]. We will initially only support `x86_64`.


## Using the cache

We can provide several ways of using the cache for the supported components.

- Cardano-node
- Kupo
- cardano-db-sync

We will provide tools to easily download snapshots for each service and start it with the snapshotted data.
For each component will provide a docker image that can be run to fetch the desired snapshot and then start off the service from there.
We will also provide a script to achieve the same without docker.

### Notes

- We can use `kupo copy` [4][4] to allow users to reduce their final DB. We will always export a copy of the DB that indexes *. Users can specify what kupo filters they want and we can restrict the DB to only those matches

- We can use  `postgresql-setup.sh --restore-snapshot` to restore snapshot on cardano-db-sync.


[1]: https://mithril.network/doc/
[2]: https://cardanosolutions.github.io/kupo/#operation/getHealth
[3]: https://github.com/input-output-hk/cardano-db-sync/blob/release/13.1.1.x/doc/state-snapshot.md#things-to-note
[4]: https://github.com/CardanoSolutions/kupo/blob/master/CHANGELOG.md#240---2023-02-23
