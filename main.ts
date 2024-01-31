import { SnapshotExporter, SnapshotConfig } from './snapshot'
import checkKupo from './components/kupo/watcher'

const minutesToMilliseconds = (minutes: number) => minutes * 60 * 1000

const kupoConfig: SnapshotConfig = {
  name: 'kupo',
  checkSnapshotState: checkKupo,
  snapshotLocation: './test/test.txt',
  snapshotTarName: 'test.tgz'
}

const main = async () => {
  const kupoSnapshot = new SnapshotExporter(kupoConfig, minutesToMilliseconds(0.01), 1)
  const result = await kupoSnapshot.run()
  console.log(result)
}

main()
