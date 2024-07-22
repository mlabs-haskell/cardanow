const kupoSnapshotDataPath: string = process.env.LOCAL_KUPO_DATA_PER_SNAPSHOT as string;
const cardanoDBSyncSnapshotDataPath: string = process.env.LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT as string;

const kupoExportedSnapshotPath: string = process.env.EXPORTED_KUPO_SNAPSHOT_PATH as string;
const cardanoDBSyncExportedSnapshotPath: string = process.env.EXPORTED_CARDANO_DB_SYNC_SNAPSHOT_PATH as string;

const kupoPort: string = process.env.KUPO_PORT as string;

// Database connection details
const postgresHost: string = process.env.POSTGRES_HOST as string;
const postgresUser: string = process.env.POSTGRES_USER as string;
const postgresPassword: string = process.env.POSTGRES_PASSWORD as string;
const postgresDb: string = process.env.POSTGRES_DB as string;
const postgresPort: number = parseInt(process.env.POSTGRES_PORT as string, 10);
// Expected epoch number
const epoch: number = parseInt(process.env.EPOCH as string, 10);

// Collecting missing environment variables
let missingVars: string[] = [];

if (!kupoSnapshotDataPath) missingVars.push('LOCAL_KUPO_DATA_PER_SNAPSHOT');
if (!cardanoDBSyncSnapshotDataPath) missingVars.push('LOCAL_CARDANO_DB_SYNC_DATA_PER_SNAPSHOT');
if (!kupoExportedSnapshotPath) missingVars.push('EXPORTED_KUPO_SNAPSHOT_PATH');
if (!cardanoDBSyncExportedSnapshotPath) missingVars.push('EXPORTED_CARDANO_DB_SYNC_SNAPSHOT_PATH');
if (!kupoPort) missingVars.push('KUPO_PORT');
if (!postgresHost) missingVars.push('POSTGRES_HOST');
if (!postgresUser) missingVars.push('POSTGRES_USER');
if (!postgresPassword) missingVars.push('POSTGRES_PASSWORD');
if (!postgresDb) missingVars.push('POSTGRES_DATABASE');
if (!postgresPort) missingVars.push('POSTGRES_PORT');
if (isNaN(epoch)) missingVars.push('EPOCH');

if (missingVars.length > 0) {
  console.error("The following environment variables are not set properly or have invalid values:");
  missingVars.forEach(variable => console.error(`- ${variable}`));
  process.exit(1);
}

export { 
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
  epoch
};
