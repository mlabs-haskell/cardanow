rec {
  CONTAINER_IPC_PATH = "/ipc";
  CONTAINER_SOCKET_PATH = "${CONTAINER_IPC_PATH}/node.socket";
  CONTAINER_CONFIG_BASE_PATH = "/config";
  CONTAINER_DATA_PATH = "/data";
  CONTAINER_DATA_CARDANO_NODE_PATH = "${CONTAINER_DATA_PATH}";
  CONTAINER_DATA_KUPO_PATH = "${CONTAINER_DATA_PATH}/kupo";
  CONTAINER_DATA_CARDANO_DB_SYNC_PATH = "${CONTAINER_DATA_PATH}/cardano-db-sync";
  LOCAL_CONFIG_PATH = "./cardano-configurations/network";
  EXPORTED_SNAPSHOT_BASE_PATH = "./exported-snapshots";
  EXPORTED_SNAPSHOT_SUMMARY_FILE_PATH = "./exported-snapshots/available-snapshots.json";
  BUCKET_NAME = "cardanow";
  BUCKET_LOCATION = "s3://${BUCKET_NAME}";
  AWS_DEFAULT_REGION = "auto";
  AWS_ENDPOINT_URL = "https://5c90369860b916812808cd543a1d782b.r2.cloudflarestorage.com";
  AWS_PUBLIC_ENDPOINT_URL = "https://pub-b887f41ffaa944ebaae543199d43421c.r2.dev";
  PGDATABASE = "cexplorer";
  PGUSER = "postgres";
  PGHOST = "0.0.0.0";
  # TODO will be deprecated when pushgateway will be 
  PUSHGATEWAY_URL = "localhost:9094";
}

