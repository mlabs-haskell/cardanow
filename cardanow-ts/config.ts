const kupoSnapshotDataPath = process.env.LOCAL_KUPO_DATA_PER_SNAPSHOT;
const cardanoDBSyncSnapshotDataPath = process.env.LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT;

const kupoExportedSnapshotPath = process.env.EXPORTED_KUPO_SNAPSHOT_PATH;
const cardanoDBSyncExportedSnapshotPath = process.env.EXPORTED_CARDANO_DB_SYNC_SNAPSHOT_PATH;

const kupoPort = process.env.KUPO_PORT;

if (
     kupoSnapshotDataPath === undefined 
  || cardanoDBSyncSnapshotDataPath === undefined 

  || cardanoDBSyncExportedSnapshotPath === undefined 
  || kupoExportedSnapshotPath === undefined 

  || kupoPort === undefined
) {
  console.error("Env variables not set properly");
  process.exit(1);
}

export { 
  // Data paths
  kupoSnapshotDataPath, 
  cardanoDBSyncSnapshotDataPath,

  // Exported snapshot paths
  kupoExportedSnapshotPath , 
  cardanoDBSyncExportedSnapshotPath, 

  // Ports
  kupoPort, 
};
