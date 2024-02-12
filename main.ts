import { SnapshotExporter, SnapshotConfig } from './snapshot'
import checkKupo from './components/kupo/watcher'

const kupoSnapshotDataPath = process.env.LOCAL_KUPO_DATA_PER_SNAPSHOT;
const exportedSnapshotPath = process.env.EXPORTED_KUPO_SNAPSHOT_PATH;

if (kupoSnapshotDataPath === undefined || exportedSnapshotPath === undefined) {
  console.error("Env variables not set");
  process.exit(1);
}

const minutesToMilliseconds = (minutes: number) => minutes * 60 * 1000

const kupoConfig: SnapshotConfig = {
  name: 'kupo',
  checkSnapshotState: checkKupo,
  snapshotLocation: kupoSnapshotDataPath,
  snapshotTarName: exportedSnapshotPath 
}
// FIXME (albertodvp 2024-02-07): this function is not robust,
// failures and retries should be addressed better
// these should also be configurable
const main = async () => {
  const kupoSnapshot = new SnapshotExporter(
    kupoConfig,
    minutesToMilliseconds(5),
    25)
  const result = await kupoSnapshot.run()
  console.log(result)
}

main()
