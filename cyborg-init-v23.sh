#!/bin/bash

echo "🧠 CYBORG-OS v23: Starship Memory Core kuruluyor..."

ROOT=$(pwd)

mkdir -p $ROOT/src/cli
mkdir -p $ROOT/memory/snapshots
mkdir -p $ROOT/sync/state
mkdir -p $ROOT/telemetry/events

# === SNAPSHOT ENGINE ===
cat << 'JS' > $ROOT/src/cli/cyborg-snapshot.js
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
JS

chmod +x $ROOT/src/cli/cyborg-snapshot.js

# === SNAPSHOT DIFF ENGINE ===
cat << 'JS' > $ROOT/src/cli/cyborg-snapshot-diff.js
#!/usr/bin/env node
import fs from "fs";
import path from "path";

const root = process.cwd();
const snapDir = path.join(root, "memory/snapshots");

const snaps = fs.readdirSync(snapDir).filter(f => f.endsWith(".json")).sort();

if (snaps.length < 2) {
  console.log("⚠️ Not enough snapshots to diff.");
  process.exit(0);
}

const a = JSON.parse(fs.readFileSync(path.join(snapDir, snaps[snaps.length - 2]), "utf8"));
const b = JSON.parse(fs.readFileSync(path.join(snapDir, snaps[snaps.length - 1]), "utf8"));

console.log("🧠 Snapshot Diff:");
console.log("Old:", snaps[snaps.length - 2]);
console.log("New:", snaps[snaps.length - 1]);

let changes = [];

for (const key of Object.keys(b)) {
  if (!a[key]) {
    changes.push({ file: key, change: "added" });
    continue;
  }
  if (JSON.stringify(a[key]) !== JSON.stringify(b[key])) {
    changes.push({ file: key, change: "modified" });
  }
}

for (const key of Object.keys(a)) {
  if (!b[key]) {
    changes.push({ file: key, change: "removed" });
  }
}

console.log(JSON.stringify(changes, null, 2));
JS

chmod +x $ROOT/src/cli/cyborg-snapshot-diff.js

# === ROLLBACK ENGINE ===
cat << 'JS' > $ROOT/src/cli/cyborg-rollback.js
#!/usr/bin/env node
import fs from "fs";
import path from "path";

const root = process.cwd();
const snapDir = path.join(root, "memory/snapshots");
const stateDir = path.join(root, "sync/state");

const snaps = fs.readdirSync(snapDir).filter(f => f.endsWith(".json")).sort();

if (snaps.length === 0) {
  console.log("❌ No snapshots found.");
  process.exit(1);
}

const latest = snaps[snaps.length - 1];
const data = JSON.parse(fs.readFileSync(path.join(snapDir, latest), "utf8"));

console.log("🧠 Rolling back to snapshot:", latest);

for (const file of Object.keys(data)) {
  const target = path.join(stateDir, file);
  fs.writeFileSync(target, JSON.stringify(data[file], null, 2));
}

console.log("✅ Rollback complete.");
JS

chmod +x $ROOT/src/cli/cyborg-rollback.js

echo "✅ CYBORG-OS v23 Starship Memory Core tamamlandı!"
