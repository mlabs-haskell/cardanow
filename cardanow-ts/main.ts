import { SnapshotExporter, SnapshotConfig } from './snapshot'
import checkKupo from './kupo-watcher'
import checkCardanoDBSync from './cardano-db-sync-watcher'
import config from './config';

const minutesToMilliseconds = (minutes: number) => minutes * 60 * 1000

const kupoConfig: SnapshotConfig = {
  name: 'kupo',
  checkSnapshotState: checkKupo,
  snapshotLocation: config.kupoSnapshotDataPath,
  snapshotTarName: config.kupoExportedSnapshotPath 
}

const cardanoDBSyncConfig: SnapshotConfig = {
  name: 'cardano-db-sync',
  checkSnapshotState: checkCardanoDBSync,
  snapshotLocation: config.cardanoDBSyncSnapshotDataPath,
  snapshotTarName: config.cardanoDBSyncExportedSnapshotPath
}
// FIXME (albertodvp 2024-02-07): this function is not robust,
// failures and retries should be addressed better
// these should also be configurable
const main = async () => {
  const kupoSnapshot = new SnapshotExporter(
    kupoConfig,
    minutesToMilliseconds(30),
    200)
  const cardanoDBSyncSnapshot = new SnapshotExporter(
    cardanoDBSyncConfig,
    // TODO change before deploy
    minutesToMilliseconds(30),
    200)

  const [kupoResult, cardanoDBSyncResult] = await Promise.all([
    kupoSnapshot.run(),
    cardanoDBSyncSnapshot.run(),
  ]);

  console.log("Kupo result", kupoResult);
  console.log("CardanoDBSync result", cardanoDBSyncResult);
}

main()
