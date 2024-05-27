const kupoSnapshotDataPath = process.env.LOCAL_KUPO_DATA_PER_SNAPSHOT;
const exportedSnapshotPath = process.env.EXPORTED_KUPO_SNAPSHOT_PATH;
const kupoPort = process.env.KUPO_PORT;

if (kupoSnapshotDataPath === undefined || exportedSnapshotPath === undefined || kupoPort === undefined) {
  console.error("Env variables not set");
  process.exit(1);
}

export { kupoSnapshotDataPath, exportedSnapshotPath, kupoPort };
