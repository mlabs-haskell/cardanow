import { describe, it, expect, vi, beforeEach, type Mock } from 'vitest';
import { main } from './../cardano-db-sync-watcher';
import { createDirectory, connectToDatabase, getEpochNumber, executePgDump } from './../cardano-db-sync-watcher-utils';
import config from '../config';


// Mock all dependencies
vi.mock('./../cardano-db-sync-watcher-utils', () => ({
  createDirectory: vi.fn(),
  connectToDatabase: vi.fn(),
  getEpochNumber: vi.fn(),
  executePgDump: vi.fn(),
}));

describe('main', () => {
  let mockClient: { end: Mock };

  beforeEach(() => {
    vi.resetAllMocks();
    mockClient = {
      end: vi.fn().mockResolvedValue(undefined),
    };
  });

  it('should create directory and connect to the database', async () => {
    // Arrange
    (connectToDatabase as unknown as Mock).mockResolvedValue(mockClient);
    (getEpochNumber as unknown as Mock).mockResolvedValue(config.epoch);

    // Act
    const result = await main();

    // Assert
    expect(createDirectory).toHaveBeenCalledWith(config.cardanoDBSyncSnapshotDataPath);
    expect(connectToDatabase).toHaveBeenCalled();
    expect(getEpochNumber).toHaveBeenCalledWith(mockClient);
    expect(executePgDump).toHaveBeenCalledWith(config.postgresDb, config.cardanoDBSyncSnapshotDataPath);
    expect(mockClient.end).toHaveBeenCalled();
    expect(result).toBe(true);
  });

  it('should return false if epoch number does not match', async () => {
    // Arrange
    (connectToDatabase as unknown as Mock).mockResolvedValue(mockClient);
    (getEpochNumber as unknown as Mock).mockResolvedValue(config.epoch - 1);

    // Act
    const result = await main();

    // Assert
    expect(createDirectory).toHaveBeenCalledWith(config.cardanoDBSyncSnapshotDataPath);
    expect(connectToDatabase).toHaveBeenCalled();
    expect(getEpochNumber).toHaveBeenCalledWith(mockClient);
    expect(executePgDump).not.toHaveBeenCalled();
    expect(mockClient.end).toHaveBeenCalled();
    expect(result).toBe(false);
  });

  it('should return false and log an error if an exception occurs', async () => {
    // Arrange
    (connectToDatabase as unknown as Mock).mockResolvedValue(mockClient);
    (getEpochNumber as unknown as Mock).mockRejectedValue(new Error('Test error'));

    const consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});

    // Act
    const result = await main();

    // Assert
    expect(createDirectory).toHaveBeenCalledWith(config.cardanoDBSyncSnapshotDataPath);
    expect(connectToDatabase).toHaveBeenCalled();
    expect(getEpochNumber).toHaveBeenCalledWith(mockClient);
    expect(consoleErrorSpy).toHaveBeenCalledWith(new Error('Test error'));
    expect(mockClient.end).toHaveBeenCalled();
    expect(result).toBe(false);

    // Cleanup
    consoleErrorSpy.mockRestore();
  });
});

