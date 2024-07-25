import { describe, it, expect, vi, beforeEach, Mock } from 'vitest';
import * as cardanoDbSyncWatcherUtils  from '../src/cardano-db-sync-watcher-utils'
import pg from 'pg';
import main from '../src/cardano-db-sync-watcher';
import config from '../src/config';

const { Client } = pg;

vi.mock('../src/cardano-db-sync-watcher-utils');

vi.mock('pg');

describe('main function', () => {
  beforeEach(() => {
    vi.resetAllMocks();
  });

  it('should create a directory, connect to the database, match epoch number, and execute pg_dump', async () => {
    const mockClient = {
      connect: vi.fn().mockResolvedValue(undefined),
      query: vi.fn().mockResolvedValue({ rows: [{ epoch_no: 42 }] }),
      end: vi.fn().mockResolvedValue(undefined),
    };
    (Client as unknown as Mock).mockImplementation(() => mockClient);

    (cardanoDbSyncWatcherUtils.connectToDatabase as unknown as Mock).mockResolvedValue(mockClient);
    (cardanoDbSyncWatcherUtils.getEpochNumber as unknown as Mock).mockResolvedValue(config.epoch);
    const execDumpMock = vi.fn();
    (cardanoDbSyncWatcherUtils.executePgDump as unknown as Mock) = execDumpMock;

    const result = await main();

    expect(cardanoDbSyncWatcherUtils.connectToDatabase).toHaveBeenCalled();
    expect(cardanoDbSyncWatcherUtils.getEpochNumber).toHaveBeenCalledWith(mockClient);
    expect(cardanoDbSyncWatcherUtils.executePgDump).toHaveBeenCalledWith(config.postgresDb, config.cardanoDBSyncSnapshotDataPath);
    expect(mockClient.end).toHaveBeenCalled();
    expect(result).toBe(true);
  });

  it('should return false if the epoch number does not match', async () => {
    const mockClient = {
      connect: vi.fn().mockResolvedValue(undefined),
      query: vi.fn().mockResolvedValue({ rows: [{ epoch_no: 40 }] }),
      end: vi.fn().mockResolvedValue(undefined),
    };

    (cardanoDbSyncWatcherUtils.connectToDatabase as unknown as Mock).mockResolvedValue(mockClient);
    (cardanoDbSyncWatcherUtils.getEpochNumber as unknown as Mock).mockResolvedValue(40);

    const result = await main();

    expect(cardanoDbSyncWatcherUtils.connectToDatabase).toHaveBeenCalled();
    expect(cardanoDbSyncWatcherUtils.getEpochNumber).toHaveBeenCalledWith(mockClient);
    expect(cardanoDbSyncWatcherUtils.executePgDump).not.toHaveBeenCalled();
    expect(mockClient.end).toHaveBeenCalled();
    expect(result).toBe(false);
  });

  it('should handle errors and return false if an exception occurs', async () => {
    const error = new Error('Test error');
    const mockClient = {
      connect: vi.fn().mockRejectedValue(error),
      end: vi.fn().mockResolvedValue(undefined),
    };

    (cardanoDbSyncWatcherUtils.connectToDatabase as unknown as Mock).mockResolvedValue(mockClient);

    const result = await main();

    expect(cardanoDbSyncWatcherUtils.connectToDatabase).toHaveBeenCalled();
    expect(cardanoDbSyncWatcherUtils.executePgDump).not.toHaveBeenCalled();
    expect(mockClient.end).toHaveBeenCalled();
    expect(result).toBe(false);

  });

  it('should ensure client is properly ended in case of an error', async () => {
    const error = new Error('Test error');
    const mockClient = {
      connect: vi.fn().mockResolvedValue(undefined),
      end: vi.fn().mockResolvedValue(undefined),
      query: vi.fn().mockRejectedValue(error),
    };

    (cardanoDbSyncWatcherUtils.connectToDatabase as unknown as Mock).mockResolvedValue(mockClient);

    const result = await main();

    expect(cardanoDbSyncWatcherUtils.connectToDatabase).toHaveBeenCalled();
    expect(mockClient.end).toHaveBeenCalled();
    expect(result).toBe(false);
  });
});
