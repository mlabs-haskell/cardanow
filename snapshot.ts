import tar from 'tar'
import crypto from 'crypto'
import fs from 'fs'
import { pipeline } from 'stream/promises'
import { PassThrough } from 'stream'

// Helpers

// Type for IO actions
type Action<T> = () => Promise<T>

// Return a promise that resolves after `time` milliseconds
const delay = (time: number) => new Promise((resolve, _) => setTimeout(resolve, time))

// Passthrough stream that also writes to a file. Used to create tgz and calculate the hash in one pass
const fileWriterPassThrough = (path: string) => {
  const p = new PassThrough()
  const f = fs.createWriteStream(path)
  p.on('data', (chunk) => f.write(chunk))
  p.on('end', () => f.end())
  return p
}

// Custom error that is not exported. Used to detect if max attempts is reached and we should give up on running the export
class MaximumAttemptsError extends Error {
  constructor() {
    super("Maximum attempts exhausted")
    this.name = "MaximumAttemptsError"
  }
}

// SnapshotExporter class
export type SnapshotConfig = {
  name: string // Identifier of the snapshot exporter process. Used in error messages
  checkSnapshotState: Action<boolean> // An IO action that checks if the snapshot is ready to be exported
  snapshotLocation: string // Location of the snapshot once checkSnapshotState returns true
  snapshotTarName: string // Name of the output snapshot
}

export class SnapshotExporter {
  readonly config: SnapshotConfig
  readonly cadence: number // Execution cadence in milliseconds. The first run will wait for `cadence` ms before executing
  readonly maxAttempts: number // Maximum number of attempts
  attempt: number // Current attempt
  
  constructor (config: SnapshotConfig, cadence?: number, maxAttempts?: number) {
    this.config = config
    this.maxAttempts = maxAttempts ?? 200
    this.cadence = cadence ?? 600000
    this.attempt = 0
  }

  private runWithDelay: Action<string> = async () => {
    this.attempt++
    console.log(`${this.config.name}: Running attempt #${this.attempt}`)

    await delay(this.cadence)
    let isSnapshotReady

    // Wrap in try/catch to handle any exceptions coming from the IO action.
    // Exceptions will be treated like normal failures.
    try {
      isSnapshotReady = await this.config.checkSnapshotState()
    } catch (e) {
      console.log(e)
      isSnapshotReady = false
    }
  
    console.log(`${this.config.name}: is snapshot ready? ${isSnapshotReady}`)

    if (isSnapshotReady) return this.handleSuccess()
    else return this.handleFailure()
  }

  private handleSuccess: Action<string> = async () => {
    const sha: string = await this.pkg()
    console.log(`${this.config.name}: Done`)
    return sha
  }

  private handleFailure: Action<string> = async () => {
    if (this.attempt < this.maxAttempts) {
      return this.run()
    }
    else {
      // This is the only kind of error that will not cause a retry
      return Promise.reject(new MaximumAttemptsError())
    }
  }

  private pkg: Action<string> = async () => {
    console.log(`${this.config.name}: packaging...`)
    
    const hash = crypto
      .createHash('sha256')
      .setEncoding('hex')

    await pipeline(
      tar.c(
        {
          gzip: true,
        },
        [this.config.snapshotLocation]
      ),
      fileWriterPassThrough(this.config.snapshotTarName),
      hash
    )

    return hash.read()
  }
  
  run: Action<string> = async () => {
    return this.runWithDelay()
      .catch((e) => {
        if (e instanceof MaximumAttemptsError) {
          throw e
        } else {
          console.error(`${this.config.name}: ${e}`)
          return this.handleFailure()
        }
      })
  }
}
