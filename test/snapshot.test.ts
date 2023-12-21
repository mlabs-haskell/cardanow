import { expect, test, describe } from 'vitest'
import { SnapshotExporter, SnapshotConfig } from '../snapshot'
import fs from 'fs/promises'

const alwaysSuccessConfig: SnapshotConfig = {
  name: 'test',
  checkSnapshotState: () => Promise.resolve(true),
  snapshotLocation: './test.txt',
  snapshotTarName: 'test.tgz'
}

const alwaysFailureConfig: SnapshotConfig = {
  name: 'test',
  checkSnapshotState: () => Promise.resolve(false),
  snapshotLocation: './test.txt',
  snapshotTarName: 'test.tgz'
}

const throwingConfig: SnapshotConfig = {
  name: 'test',
  checkSnapshotState: () => { throw new Error('A') },
  snapshotLocation: './test.txt',
  snapshotTarName: 'test.tgz'
}

describe('Snapshot', () => {
  test('Should calculate correct hash for test file', async () => {
    const testSnapshot = new SnapshotExporter(alwaysSuccessConfig, 10)
    expect(await testSnapshot.run()).toEqual('c3615e1d51b9ccc6c9028e99e3ed03eb252704f9fa285002b6f7c1bab966cdee')
  })

  test('Should give up after 20 attempts', async () => {
    const testSnapshot = new SnapshotExporter(alwaysFailureConfig, 10, 20)
    await expect(testSnapshot.run()).rejects.toThrowError(Error('Maximum attempts exhausted'))
    expect(testSnapshot.attempt).toEqual(20)
  })

  test('Should exhaust all attempts despite checkSnapshotState throwing', async () => {
    const testSnapshot = new SnapshotExporter(throwingConfig, 10, 10)
    await expect(testSnapshot.run()).rejects.toThrowError(Error('Maximum attempts exhausted'))
    await expect(testSnapshot.attempt).toEqual(10)
  })
})
