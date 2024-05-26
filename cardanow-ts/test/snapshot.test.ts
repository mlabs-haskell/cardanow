import { expect, test, describe } from 'vitest'
import { SnapshotExporter, SnapshotConfig } from '../snapshot'


const alwaysSuccessConfig: SnapshotConfig = {
  name: 'test',
  checkSnapshotState: () => Promise.resolve(true),
  snapshotLocation: './test/test.txt',
  snapshotTarName: 'test.tgz'
}

const alwaysFailureConfig: SnapshotConfig = {
  name: 'test',
  checkSnapshotState: () => Promise.resolve(false),
  snapshotLocation: './test/test.txt',
  snapshotTarName: 'test.tgz'
}

const throwingConfig: SnapshotConfig = {
  name: 'test',
  checkSnapshotState: () => { throw new Error('Will never be ready') },
  snapshotLocation: './test/test.txt',
  snapshotTarName: 'test.tgz'
}

describe('Snapshot', () => {
  test('Should calculate correct hash for test file', async () => {
    const testSnapshot = new SnapshotExporter(alwaysSuccessConfig, 10)
    expect(await testSnapshot.run()).toEqual('ab00e43f54af3f30d81e383f91c6314beda6354e9f3cde0309679dcbe17d3ad0')
  })

  test('Should give up after 20 attempts', async () => {
    const testSnapshot = new SnapshotExporter(alwaysFailureConfig, 10, 20)
    await expect(testSnapshot.run()).rejects.toThrowError(Error('Maximum attempts exhausted'))
    expect(testSnapshot.attempt).toEqual(20)
  })

  test('Should exhaust all attempts despite checkSnapshotState throwing', async () => {
    const testSnapshot = new SnapshotExporter(throwingConfig, 10, 10)
    await expect(testSnapshot.run()).rejects.toThrowError(Error('Maximum attempts exhausted'))
    expect(testSnapshot.attempt).toEqual(10)
  })
})
