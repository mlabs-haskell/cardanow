- You will need to install the node depdendencies. You only need this step once

```
npm i
```

- Use the `dowload-mithril-snapshot.sh` script to download the snapshot. You will need to specify a NETWORK env var

```
NETWORK=preview ./components/cardano-node/dowload-mithril-snapshot.sh
```

- Start the compose environment. You will need to specify a NETWORK env var

```
NETWORK=preview docker-compose up -d
```

- Run the application

```
npm test
```


## Notes

The following binaries must be available on the host machine:

- mithril-client (v0.5.5)
- cardano-cli (v1.35.3)
- cardano-db-tool ??
