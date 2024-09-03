{ network }:

rec {
  NETWORK = network;
  CARDANO_NODE_FLAG =
    if network == "preview" then "--testnet-magic 2"
    else if network == "preprod" then "--testnet-magic 1"
    else "--mainnet";

  KUPO_PORT =
    if network == "preview" then "1442"
    else if network == "preprod" then "1443"
    else "1444";

  PGPORT =
    if network == "preview" then "12344"
    else if network == "preprod" then "12345"
    else "12346";

  SNAPSHOTS_BASE_DIR = "./snapshots/${network}";
  SNAPSHOTS_CARDANO_NODE_DIR = "${SNAPSHOTS_BASE_DIR}/cardano-node";
  SNAPSHOTS_KUPO_DIR = "${SNAPSHOTS_BASE_DIR}/kupo";
  SNAPSHOTS_CARDANO_DB_SYNC_DIR = "${SNAPSHOTS_BASE_DIR}/cardano-db-sync";
  MITHRIL_CONFIG = "./mithril-configurations/${network}.env";
  CONTAINER_CONFIG_PATH = "/config/${network}/cardano-node";
  CONTAINER_CONFIG_CONFIG_PATH = "${CONTAINER_CONFIG_PATH}/config.json";
  CONTAINER_CONFIG_TOPOLOGY_PATH = "${CONTAINER_CONFIG_PATH}/topology.json";
  EXPORTED_SNAPSHOT_BASE_PATH_WITH_DATA_SOURCE_KUPO = "./exported-snapshots/${network}/kupo";
  EXPORTED_SNAPSHOT_BASE_PATH_WITH_DATA_SOURCE_CARDANO_DB_SYNC = "./exported-snapshots/${network}/cardano-db-sync";
}
