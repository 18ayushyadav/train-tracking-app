#!/usr/bin/env node
/**
 * seed_towers.js
 * Reads seed_towers.json and inserts data into the app's SQLite database.
 * Used for development / first-run setup.
 *
 * Usage:  node scripts/seed_towers.js [path/to/towers_db.sqlite]
 */
"use strict";

const path = require("path");
const fs = require("fs");
const Database = require("better-sqlite3");

const DB_PATH = process.argv[2] || path.join(__dirname, "../data/towers.sqlite");
const JSON_PATH = path.join(__dirname, "../train_tracker_app/assets/data/seed_towers.json");

if (!fs.existsSync(JSON_PATH)) {
    console.error(`❌ Cannot find seed JSON at: ${JSON_PATH}`);
    process.exit(1);
}

const towers = JSON.parse(fs.readFileSync(JSON_PATH, "utf8"));
const db = new Database(DB_PATH);

// Ensure table exists
db.exec(`
  CREATE TABLE IF NOT EXISTS cell_towers (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    mcc          INTEGER NOT NULL,
    mnc          INTEGER NOT NULL,
    cid          INTEGER NOT NULL,
    lac          INTEGER NOT NULL,
    lat          REAL    NOT NULL,
    lon          REAL    NOT NULL,
    route_code   TEXT,
    station_near TEXT
  );
  CREATE INDEX IF NOT EXISTS idx_cid ON cell_towers(cid);
  CREATE INDEX IF NOT EXISTS idx_lac ON cell_towers(lac);
`);

const insert = db.prepare(`
  INSERT OR REPLACE INTO cell_towers (mcc, mnc, cid, lac, lat, lon, route_code, station_near)
  VALUES (@mcc, @mnc, @cid, @lac, @lat, @lon, @route_code, @station_near)
`);

const insertMany = db.transaction((rows) => {
    rows.forEach(r => insert.run(r));
});

insertMany(towers);

console.log(`✅ Inserted ${towers.length} towers into ${DB_PATH}`);
db.close();
