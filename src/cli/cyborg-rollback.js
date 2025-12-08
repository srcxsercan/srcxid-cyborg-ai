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
