// Define the TypeScript interface for your configuration
export interface Config {
  // Data paths
  kupoSnapshotDataPath: string;
  cardanoDBSyncSnapshotDataPath: string;

  // Exported snapshot paths
  kupoExportedSnapshotPath: string;
  cardanoDBSyncExportedSnapshotPath: string;

  // Ports
  kupoPort: string;

  // Database connection details
  postgresHost: string;
  postgresUser: string;
  postgresPassword: string;
  postgresDb: string;
  postgresPort: number;

  // Expected epoch number
  epoch: number;

  // The cardano network
  network: string;
}

// Define environment variables and their defaults
const kupoSnapshotDataPath: string = process.env.LOCAL_KUPO_DATA_PER_SNAPSHOT as string;
const cardanoDBSyncSnapshotDataPath: string = process.env.LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT as string;

const kupoExportedSnapshotPath: string = process.env.EXPORTED_KUPO_SNAPSHOT_PATH as string;
const cardanoDBSyncExportedSnapshotPath: string = process.env.EXPORTED_CARDANO_DB_SYNC_SNAPSHOT_PATH as string;

const kupoPort: string = process.env.KUPO_PORT as string;

// Database connection details
const postgresHost: string = process.env.PGHOST as string;
const postgresUser: string = process.env.PGUSER as string;
const postgresPassword: string = process.env.PGPASSWORD as string;
const postgresDb: string = process.env.PGDATABASE as string;
const postgresPort: number = parseInt(process.env.PGPORT as string, 10);
// Expected epoch number
const epoch: number = parseInt(process.env.EPOCH as string, 10);

// Cardano network
const network: string = process.env.NETWORK as string;

// Collecting missing environment variables
let missingVars: string[] = [];

if (!kupoSnapshotDataPath) missingVars.push('LOCAL_KUPO_DATA_PER_SNAPSHOT');
if (!cardanoDBSyncSnapshotDataPath) missingVars.push('LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT');
if (!kupoExportedSnapshotPath) missingVars.push('EXPORTED_KUPO_SNAPSHOT_PATH');
if (!cardanoDBSyncExportedSnapshotPath) missingVars.push('EXPORTED_CARDANO_DB_SYNC_SNAPSHOT_PATH');
if (!kupoPort) missingVars.push('KUPO_PORT');
if (!postgresHost) missingVars.push('PGHOST');
if (!postgresUser) missingVars.push('PGUSER');
if (!postgresPassword) missingVars.push('PGPASSWORD');
if (!postgresDb) missingVars.push('PGDATABASE');
if (!postgresPort) missingVars.push('PGPORT');
if (isNaN(epoch)) missingVars.push('EPOCH');
if (!network) missingVars.push('NETWORK');

if (missingVars.length > 0) {
  console.error("The following environment variables are not set properly or have invalid values:");
  missingVars.forEach(variable => console.error(`- ${variable}`));
  process.exit(1);
}

// Define and export the configuration object
const config: Config = {
  // Data paths
  kupoSnapshotDataPath,
  cardanoDBSyncSnapshotDataPath,

  // Exported snapshot paths
  kupoExportedSnapshotPath,
  cardanoDBSyncExportedSnapshotPath,

  // Ports
  kupoPort,

  // Database connection details
  postgresHost,
  postgresUser,
  postgresPassword,
  postgresDb,
  postgresPort,

  // Expected epoch number
  epoch,

  // ardano network
  network
};

// Export the configuration object and the Config type
export default config;
