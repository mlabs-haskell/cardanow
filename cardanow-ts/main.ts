import { SnapshotExporter, SnapshotConfig } from './snapshot'
import checkKupo from './kupo-watcher'

const kupoSnapshotDataPath = process.env.LOCAL_KUPO_DATA_PER_SNAPSHOT;
const exportedSnapshotPath = process.env.EXPORTED_KUPO_SNAPSHOT_PATH;
const kupoPort = process.env.KUPO_PORT;

if (kupoSnapshotDataPath === undefined || exportedSnapshotPath === undefined || kupoPort === undefined ) {
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
    minutesToMilliseconds(30),
    200)
  const result = await kupoSnapshot.run()
  console.log(result)
}

main()
