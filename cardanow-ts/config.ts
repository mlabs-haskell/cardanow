const kupoSnapshotDataPath: string = process.env.LOCAL_KUPO_DATA_PER_SNAPSHOT as string;
const cardanoDBSyncSnapshotDataPath: string = process.env.LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT as string;

const kupoExportedSnapshotPath: string = process.env.EXPORTED_KUPO_SNAPSHOT_PATH as string;
const cardanoDBSyncExportedSnapshotPath: string = process.env.EXPORTED_CARDANO_DB_SYNC_SNAPSHOT_PATH as string;

const kupoPort: string = process.env.KUPO_PORT as string;

if (
  !kupoSnapshotDataPath 
  || !cardanoDBSyncSnapshotDataPath 

  || !kupoExportedSnapshotPath 
  || !cardanoDBSyncExportedSnapshotPath 

  || !kupoPort
) {
  console.error("Env variables not set properly");
  process.exit(1);
}

export { 
  // Data paths
  kupoSnapshotDataPath, 
  cardanoDBSyncSnapshotDataPath,

  // Exported snapshot paths
  kupoExportedSnapshotPath, 
  cardanoDBSyncExportedSnapshotPath, 

  // Ports
  kupoPort, 
};
