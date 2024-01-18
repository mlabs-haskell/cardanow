import pg from "pg"
import path from "path"
import fs from "fs"
import { execSync } from 'child_process'

const { Pool } = pg

const pgFilesDir = path.join(__dirname, "..", "..", "configurations", "postgres", "secrets")

const db = fs.readFileSync(path.join(pgFilesDir, "db"), "utf-8")
const user = fs.readFileSync(path.join(pgFilesDir, "user"), "utf-8")
const pass = fs.readFileSync(path.join(pgFilesDir, "password"), "utf-8")

const pool = new Pool({
  user,
  password: pass,
  database: db,
  host: "localhost",
  port: 5432
})

const query = (text: string, params: string[]) => pool.query(text, params)

export default (nodeBlockTip: number) => {
  return async () => {
    // Query db to check latest block
    const dbSyncTip = await query("SELECT slot_no FROM block WHERE block_no IS NOT NULL ORDER BY block_no DESC LIMIT 1;", [])
    
    if (dbSyncTip < nodeBlockTip) return false
    const command = execSync("cardano-db-tool prepare-snapshot --state-dir db-sync-data", {
      env: {
        PGPASSFILE: path.join(pgFilesDir, "pgpass"),
        PGUSER: user,
        PGPASSWORD: pass,
        PGDATABASE: db
      }
    })
    console.log(command)
    // Run db-tool on 

  }
}

