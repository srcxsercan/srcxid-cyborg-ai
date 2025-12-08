#!/usr/bin/env node
import fs from "fs";
import path from "path";
import crypto from "crypto";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const root = process.cwd();
const stateDir = path.join(root, "sync/state");
const eventDir = path.join(root, "telemetry/events");

if (!fs.existsSync(stateDir)) fs.mkdirSync(stateDir, { recursive: true });
if (!fs.existsSync(eventDir)) fs.mkdirSync(eventDir, { recursive: true });

const nodeName = process.argv[2] || "node-local";
const action = process.argv[3] || "push";

console.log("🌐 Starship Sync Engine");
console.log("Node:", nodeName);
console.log("Action:", action);

const stateFile = path.join(stateDir, `${nodeName}.json`);

function loadState(file) {
  if (!fs.existsSync(file)) return { node: nodeName, timestamp: 0, data: {} };
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function saveState(file, state) {
  fs.writeFileSync(file, JSON.stringify(state, null, 2));
}

function mergeStates(a, b) {
  return {
    node: a.node,
    timestamp: Math.max(a.timestamp, b.timestamp),
    data: { ...a.data, ...b.data }
  };
}

if (action === "push") {
  const now = Date.now();
  const newState = {
    node: nodeName,
    timestamp: now,
    data: {
      heartbeat: new Date().toISOString(),
      hash: crypto.randomBytes(8).toString("hex")
    }
  };

  saveState(stateFile, newState);
  console.log("✅ State pushed:", stateFile);

  const ts = new Date().toISOString().replace(/[:.]/g, "-");
  const eventFile = path.join(eventDir, `${ts}-sync-push.json`);
  fs.writeFileSync(eventFile, JSON.stringify({
    type: "sync_push",
    node: nodeName,
    timestamp: new Date().toISOString(),
    state: newState
  }, null, 2));

  console.log("📡 Telemetry sync event written:", eventFile);
  process.exit(0);
}

if (action === "pull") {
  const files = fs.readdirSync(stateDir).filter(f => f.endsWith(".json"));
  console.log("📥 Available states:", files);
  process.exit(0);
}

if (action === "merge") {
  const files = fs.readdirSync(stateDir).filter(f => f.endsWith(".json"));
  let merged = loadState(stateFile);

  for (const f of files) {
    const full = path.join(stateDir, f);
    const other = loadState(full);
    merged = mergeStates(merged, other);
  }

  saveState(stateFile, merged);
  console.log("✅ State merged:", stateFile);

  const ts = new Date().toISOString().replace(/[:.]/g, "-");
  const eventFile = path.join(eventDir, `${ts}-sync-merge.json`);
  fs.writeFileSync(eventFile, JSON.stringify({
    type: "sync_merge",
    node: nodeName,
    timestamp: new Date().toISOString(),
    merged
  }, null, 2));

  console.log("📡 Telemetry sync merge event written:", eventFile);
  process.exit(0);
}

console.log("❌ Unknown action. Use: push | pull | merge");
