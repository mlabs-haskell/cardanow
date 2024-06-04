import { SnapshotExporter, SnapshotConfig } from './snapshot'
import checkKupo from './kupo-watcher'
import { kupoSnapshotDataPath, exportedSnapshotPath, kupoPort } from './config';

console.log(kupoSnapshotDataPath, exportedSnapshotPath);

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
