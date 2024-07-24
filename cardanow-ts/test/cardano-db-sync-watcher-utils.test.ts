import { describe, it, expect, vi, beforeEach, Mock } from 'vitest';
import * as fs from 'fs';
import pg from 'pg';
import { execSync } from 'child_process';
import config from '../src/config';
import { createDirectory, connectToDatabase, getEpochNumber, executePgDump } from '../src/cardano-db-sync-watcher-utils';

const { Client } = pg;

vi.mock('fs');
vi.mock('child_process', () => ({
  execSync: vi.fn(),
}));
vi.mock('pg');

describe('createDirectory', () => {
  it('should create a directory recursively with the correct path', () => {
    const path = '/some/path';
    const mkdirSyncMock = vi.spyOn(fs, 'mkdirSync');

    createDirectory(path);

    expect(mkdirSyncMock).toHaveBeenCalledWith(path, { recursive: true });
  });
});


describe('connectToDatabase', () => {
  it('should create a new Client with correct parameters and call connect', async () => {
    const mockClient = {
      connect: vi.fn().mockResolvedValue(undefined),
      end: vi.fn().mockResolvedValue(undefined),
    };

    (pg.Client as unknown as Mock).mockImplementation(() => mockClient);

    const client = await connectToDatabase();

    expect(pg.Client).toHaveBeenCalledWith({
      host: config.postgresHost,
      user: config.postgresUser,
      port: config.postgresPort,
      password: config.postgresPassword,
      database: config.postgresDb,
    });
    expect(mockClient.connect).toHaveBeenCalled();
    expect(client).toBe(mockClient);
  });
});


describe('getEpochNumber', () => {
  it('should return the correct epoch number when the query returns rows', async () => {
    const mockClient = {
      query: vi.fn().mockResolvedValue({ rows: [{ epoch_no: 42 }] }),
    };

    const epochNumber = await getEpochNumber(mockClient);

    expect(mockClient.query).toHaveBeenCalledWith('SELECT epoch_no FROM block WHERE epoch_no IS NOT NULL ORDER BY epoch_no DESC LIMIT 1');
    expect(epochNumber).toBe(42);
  });

  it('should return null when the query returns no rows', async () => {
    const mockClient = {
      query: vi.fn().mockResolvedValue({ rows: [] }),
    };

    const epochNumber = await getEpochNumber(mockClient);

    expect(mockClient.query).toHaveBeenCalledWith('SELECT epoch_no FROM block WHERE epoch_no IS NOT NULL ORDER BY epoch_no DESC LIMIT 1');
    expect(epochNumber).toBeNull();
  });

  it('should return null when the query returns rows with null values', async () => {
    const mockClient = {
      query: vi.fn().mockResolvedValue({ rows: [{ epoch_no: null }] }),
    };

    const epochNumber = await getEpochNumber(mockClient);

    expect(mockClient.query).toHaveBeenCalledWith('SELECT epoch_no FROM block WHERE epoch_no IS NOT NULL ORDER BY epoch_no DESC LIMIT 1');
    expect(epochNumber).toBeNull();
  });
});

describe('executePgDump', () => {
  it('should call execSync with the correct command', () => {
    const db = 'my_database';
    const path = '/path/to/dump';
    const expectedCommand = `pg_dump --no-owner --schema=public --jobs=4 ${db} --format=directory --file=${path}`;

    executePgDump(db, path);

    expect(execSync).toHaveBeenCalledWith(expectedCommand, { stdio: 'inherit' });
  });
});
