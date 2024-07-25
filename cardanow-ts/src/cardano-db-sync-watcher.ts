import config from './config';

import { connectToDatabase, createDirectory, executePgDump, getEpochNumber } from './cardano-db-sync-watcher-utils';

export const main = async (): Promise<boolean> => {
  let client;
  try {
    createDirectory(config.cardanoDBSyncSnapshotDataPath);
    client = await connectToDatabase();
    const epochNo = await getEpochNumber(client);

    if (epochNo === config.epoch) {
      console.log(`Epoch number matches the expected value. epochNo: ${epochNo}, expected: ${config.epoch}`);
      executePgDump(config.postgresDb, config.cardanoDBSyncSnapshotDataPath);
      console.log('pg_dump completed successfully');
      return true;
    } else {
      console.log(`Epoch number does not match the expected value. epochNo: ${epochNo}, expected: ${config.epoch}`);
      return false;
    }
  } catch (e) {
    console.error(e);
    return false;
  } finally {
    if (client) {
      await client.end();
    }
  }
};

export default main
