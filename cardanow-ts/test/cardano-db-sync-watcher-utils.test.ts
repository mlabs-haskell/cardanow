import { describe, it, expect, vi, Mock, MockedFunction, MockInstance} from 'vitest';
import * as fs from 'fs';
import pg from 'pg';
import * as child_process from 'child_process';
import { createDirectory, connectToDatabase, getEpochNumber, executePgDump} from './../src/cardano-db-sync-watcher-utils';
import config from '../src/config';

const { Client } = pg;

// Mock fs and pg modules
vi.mock('fs');

// Mock Client class
vi.mock('pg', async () => {
  const actual = <Record<string, unknown>>await vi.importActual('pg');
  return {
    ... actual,
    Client: vi.fn().mockImplementation(() => {
      return {
        connect: vi.fn().mockResolvedValue(undefined),
        query: vi.fn().mockResolvedValue(undefined),
        end: vi.fn().mockResolvedValue(undefined),
      };
    }),
  };
});

// Mock the execSync function
vi.mock('child_process', () => ({
  execSync: vi.fn(),
}));

describe('createDirectory', () => {
  it('should create a directory recursively', () => {
    const mkdirSyncMock = vi.spyOn(fs, 'mkdirSync');
    createDirectory('/some/path');
    expect(mkdirSyncMock).toHaveBeenCalledWith('/some/path', { recursive: true });
  });
});

describe('connectToDatabase', () => {
  it('should create a new Client and call connect', async () => {
    const client = await connectToDatabase();

    // Check if Client was instantiated with the correct parameters
    expect(Client).toHaveBeenCalledWith({
      host: config.postgresHost,
      user: config.postgresUser,
      port: config.postgresPort,
      password: config.postgresPassword,
      database: config.postgresDb,
    });

    // Check if connect method was called
    expect(client.connect).toHaveBeenCalled();
  });
});

describe('getEpochNumber', () => {
  it('should return the correct epoch number when the query returns rows', async () => {
    const mockClient = new Client();
    // Mock the query method to return a simulated result
    (mockClient.query as Mock).mockResolvedValue({ rows: [{ epoch_no: 42 }] });

    const epochNumber = await getEpochNumber(mockClient);

    expect(epochNumber).toBe(42);
  });

  it('should return null when the query returns no rows', async () => {
    const mockClient = new Client();
    // Mock the query method to return no rows
    mockClient.query.mockResolvedValue({ rows: [] });

    const epochNumber = await getEpochNumber(mockClient);

    expect(epochNumber).toBeNull();
  });

  it('should return null when the query returns null values', async () => {
    const mockClient = new Client();
    // Mock the query method to return rows with null epoch_no
    mockClient.query.mockResolvedValue({ rows: [{ epoch_no: null }] });

    const epochNumber = await getEpochNumber(mockClient);

    expect(epochNumber).toBeNull();
  });
});
describe('executePgDump', () => {
  it('should call execSync with the correct command', () => {
    const mockExecSync = child_process.execSync as unknown as Mock; // Cast for type safety
    const db = 'my_database';
    const path = '/path/to/dump';

    // Call the function
    executePgDump(db, path);

    // Define the expected command
    const expectedCommand = `pg_dump --no-owner --schema=public --jobs=4 ${db} --format=directory --file=${path}`;

    // Check if execSync was called with the correct command
    expect(mockExecSync).toHaveBeenCalledWith(expectedCommand, { stdio: 'inherit' });
  });
});
