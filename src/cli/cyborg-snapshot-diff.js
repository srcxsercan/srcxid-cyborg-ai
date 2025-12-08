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
