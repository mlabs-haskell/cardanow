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
  epoch
} from './config';

import * as fs from 'fs';
import { Client } from 'pg'; // PostgreSQL client for Node.js

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
    } else {
      console.log(`Epoch number does not match the expected value. epochNo: ${epochNo}, expected: ${epoch}`);
      return false;
    }

  } catch (e) {
    console.error(e);

    // Always return true even if there's an error
    return false;
  } finally {
    // Ensure the client is closed to free up resources
    if (client) {
      await client.end();
    }
  }
}
