import { describe, it, expect, vi, beforeEach, type Mock } from 'vitest';
import { main } from '../src/cardano-db-sync-watcher';
import { createDirectory, connectToDatabase, getEpochNumber, executePgDump } from '../src/cardano-db-sync-watcher-utils';
import config from '../src/config';


