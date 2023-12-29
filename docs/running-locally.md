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
