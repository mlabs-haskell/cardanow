const kupoSnapshotDataPath = process.env.LOCAL_KUPO_DATA_PER_SNAPSHOT;
const exportedSnapshotPath = process.env.EXPORTED_KUPO_SNAPSHOT_PATH;
const cardanoDBSyncSnapshotDataPath = process.env.LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT;
const cardanoDBSyncSnapshotPath = process.env.EXPORTED_CARDANO_DB_SYNC_SNAPSHOT_PATH;

const kupoPort = process.env.KUPO_PORT;
const cardanoDBSyncPort = process.env.CARDANO_DB_SYNC_PORT;

if (cardanoDBSyncSnapshotDataPath === undefined || cardanoDBSyncSnapshotPath === undefined || cardanoDBSyncPort === undefined || kupoSnapshotDataPath === undefined || exportedSnapshotPath === undefined || kupoPort === undefined) {
  console.error("Env variables not set properly");
  process.exit(1);
}

export { kupoSnapshotDataPath, exportedSnapshotPath, kupoPort };
