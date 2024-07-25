import * as fs from 'fs';
import pg from 'pg';

import { execSync } from 'child_process';
import config from './config';

const { Client } = pg;

export const createDirectory = (path: string): void => {
  fs.mkdirSync(path, { recursive: true });
};

export const connectToDatabase = async () => {
  const client = new Client({
    host: config.postgresHost,
    user: config.postgresUser,
    port: config.postgresPort,
    password: config.postgresPassword,
    database: config.postgresDb
  });
  await client.connect();
  return client;
};

export const getEpochNumber = async (client: any): Promise<number | null> => {
  const res = await client.query('SELECT epoch_no FROM block WHERE epoch_no IS NOT NULL ORDER BY epoch_no DESC LIMIT 1');
  return res.rows[0]?.epoch_no || null;
};

export const executePgDump = (db: string, path: string): void => {
  const dumpCommand = `pg_dump --no-owner --schema=public --jobs=4 ${db} --format=directory --file=${path}`;
  execSync(dumpCommand, { stdio: 'inherit' });
};
