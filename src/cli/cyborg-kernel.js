#!/usr/bin/env node
import fs from "fs";
import path from "path";

const root = process.cwd();

const teleDir = path.join(root, "telemetry/events");
const hbDir = path.join(root, "heartbeat");
const snapDir = path.join(root, "memory/snapshots");
const stateDir = path.join(root, "sync/state");

function countFiles(dir) {
  if (!fs.existsSync(dir)) return 0;
  return fs.readdirSync(dir).filter(f => f.endsWith(".json")).length;
}

console.log("🧬 Cyborg Kernel — Autonomous Check");

const telemetryCount = countFiles(teleDir);
const hbCount = countFiles(hbDir);
const snapCount = countFiles(snapDir);
const stateCount = countFiles(stateDir);

let actions = [];

if (hbCount === 0) {
  actions.push("heartbeat_missing");
}

if (snapCount === 0) {
  actions.push("create_snapshot");
}

if (stateCount === 0) {
  actions.push("request_sync");
}

let healthScore = 100;
if (telemetryCount === 0) healthScore -= 20;
if (hbCount === 0) healthScore -= 20;
if (snapCount === 0) healthScore -= 20;
if (stateCount === 0) healthScore -= 20;

console.log("📊 Kernel Health Score:", healthScore);
console.log("🧩 Suggested Actions:", actions);

const kernelDir = path.join(root, "kernel");
if (!fs.existsSync(kernelDir)) fs.mkdirSync(kernelDir, { recursive: true });

const reportFile = path.join(kernelDir, "kernel-autonomous-report.json");
fs.writeFileSync(reportFile, JSON.stringify({
  timestamp: new Date().toISOString(),
  telemetryCount,
  hbCount,
  snapCount,
  stateCount,
  healthScore,
  actions
}, null, 2));

console.log("📄 Kernel report:", reportFile);
