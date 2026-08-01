import pg from 'pg'
const client = new pg.Client({ host: 'localhost', port: 5432, user: '7carbon', password: '7carbon', database: 'postgres' })
await client.connect()
// Terminate any existing connections to the target DB, then recreate as UTF8.
await client.query(`SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='7carbon' AND pid <> pg_backend_pid()`)
await client.query('DROP DATABASE IF EXISTS "7carbon"')
await client.query(`CREATE DATABASE "7carbon" WITH ENCODING 'UTF8' TEMPLATE template0 LC_COLLATE 'C' LC_CTYPE 'C'`)
const r = await client.query('SELECT datname, pg_encoding_to_char(encoding) AS enc FROM pg_database WHERE datname=$1', ['7carbon'])
console.log('Recreated:', r.rows[0])
await client.end()
