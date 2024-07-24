import {
  // Data paths
  cardanoDBSyncSnapshotDataPath,
  // Database connection details
  postgresHost,
  postgresUser,
  postgresPassword,
  postgresDb,
  postgresPort,
  // Expected epoch number
  epoch,
} from './config';

import * as fs from 'fs';
import { Client } from 'pg'; // PostgreSQL client for Node.js
import { execSync } from 'child_process';

export default async () => {
  let client;
  try {
    // Create an empty directory at the specified data path
    fs.mkdirSync(cardanoDBSyncSnapshotDataPath, { recursive: true });

    // Initialize the PostgreSQL client
    client = new Client({
      host: postgresHost,
      user: postgresUser,
      port: postgresPort,
      password: postgresPassword,
      database: postgresDb
    });

    // Connect to the database
    await client.connect();

    // Execute the SQL query
    const res = await client.query('SELECT epoch_no FROM block WHERE epoch_no IS NOT NULL ORDER BY epoch_no DESC LIMIT 1');

    // Get the epoch_no from the result
    const epochNo = res.rows[0]?.epoch_no;

    // Check if the retrieved epoch_no is equal to the expected epoch number
    if (epochNo === epoch) {
      console.log(`Epoch number matches the expected value. epochNo: ${epochNo}, expected: ${epoch}`);

      // Define the command for pg_dump
      const dumpCommand = `pg_dump --no-owner --schema=public --jobs=4 ${postgresDb} --format=directory --file=${cardanoDBSyncSnapshotDataPath}`;


      console.log(`pg_dump command: ${dumpCommand}`);

      // Execute the pg_dump command
      try {
        // Execute the pg_dump command synchronously
        const stdout = execSync(dumpCommand, { stdio: 'inherit' });

        console.log(`pg_dump output: ${stdout}`);
        console.log('pg_dump completed successfully');
      } catch (error) {
        console.error(`Error executing pg_dump: ${error}`);
        return false;
      }

return true;
    } else {
      console.log(`Epoch number does not match the expected value. epochNo: ${epochNo}, expected: ${epoch}`);
      return false;
    }

  } catch (e) {
    console.error(e);

    return false;
  } finally {
    // Ensure the client is closed to free up resources
    if (client) {
      await client.end();
    }
  }
}
