#!/usr/bin/env node
import fs from "fs";
import path from "path";
import crypto from "crypto";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const root = process.cwd();
const stateDir = path.join(root, "sync/state");
const snapDir = path.join(root, "memory/snapshots");
const eventDir = path.join(root, "telemetry/events");

if (!fs.existsSync(snapDir)) fs.mkdirSync(snapDir, { recursive: true });

const ts = new Date().toISOString().replace(/[:.]/g, "-");
const snapFile = path.join(snapDir, `${ts}-snapshot.json`);

const files = fs.readdirSync(stateDir).filter(f => f.endsWith(".json"));
let snapshot = {};

for (const f of files) {
  const full = path.join(stateDir, f);
  try {
    const data = JSON.parse(fs.readFileSync(full, "utf8"));
    snapshot[f] = data;
  } catch {}
}

fs.writeFileSync(snapFile, JSON.stringify(snapshot, null, 2));

console.log("✅ Snapshot created:", snapFile);

// Telemetry event
if (!fs.existsSync(eventDir)) fs.mkdirSync(eventDir, { recursive: true });

const eventFile = path.join(eventDir, `${ts}-memory-snapshot.json`);
fs.writeFileSync(eventFile, JSON.stringify({
  type: "memory_snapshot",
  timestamp: new Date().toISOString(),
  snapshot_file: snapFile
}, null, 2));

console.log("📡 Telemetry memory event written:", eventFile);
