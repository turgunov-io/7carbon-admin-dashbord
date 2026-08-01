/**
 * Dockerless local PostgreSQL for development. Boots a portable embedded
 * PostgreSQL 18 on :5432 with the credentials in .env, then stays alive.
 * Data persists in dashboard/.pgdata. Stop with Ctrl+C.
 */
import EmbeddedPostgres from 'embedded-postgres'
import { existsSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, resolve } from 'node:path'

const __dirname = dirname(fileURLToPath(import.meta.url))
const dataDir = resolve(__dirname, '../.pgdata')

const pg = new EmbeddedPostgres({
  databaseDir: dataDir,
  user: '7carbon',
  password: '7carbon',
  port: 5432,
  persistent: true,
})

const firstRun = !existsSync(dataDir)
if (firstRun) {
  console.log('› Initialising database cluster…')
  await pg.initialise()
}
await pg.start()
try {
  await pg.createDatabase('7carbon')
  console.log('› Database "7carbon" created')
} catch {
  console.log('› Database "7carbon" already exists')
}
console.log('EMBEDDED_PG_READY :5432  (user=7carbon db=7carbon)')

async function shutdown() {
  console.log('\n› Stopping PostgreSQL…')
  await pg.stop().catch(() => {})
  process.exit(0)
}
process.on('SIGINT', shutdown)
process.on('SIGTERM', shutdown)
setInterval(() => {}, 1 << 30) // keep the process alive
