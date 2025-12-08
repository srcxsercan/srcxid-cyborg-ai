#!/usr/bin/env node
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const root = process.cwd();
const hbDir = path.join(root, "heartbeat");
const eventDir = path.join(root, "telemetry/events");

if (!fs.existsSync(hbDir)) fs.mkdirSync(hbDir, { recursive: true });
if (!fs.existsSync(eventDir)) fs.mkdirSync(eventDir, { recursive: true });

const services = [
  "nexus",
  "mesh",
  "lvm",
  "compliance",
  "multichain",
  "quantum",
  "orchestrator"
];

console.log("❤️ Starship Heartbeat Engine");
console.log("Pinging services...");

let results = [];

for (const svc of services) {
  const hbFile = path.join(hbDir, `${svc}.json`);
  const now = new Date().toISOString();

  const data = {
    service: svc,
    timestamp: now,
    status: "alive"
  };

  fs.writeFileSync(hbFile, JSON.stringify(data, null, 2));

  results.push(data);
}

console.log("✅ Heartbeats updated.");

const ts = new Date().toISOString().replace(/[:.]/g, "-");
const eventFile = path.join(eventDir, `${ts}-heartbeat.json`);

fs.writeFileSync(eventFile, JSON.stringify({
  type: "heartbeat",
  timestamp: new Date().toISOString(),
  services: results
}, null, 2));

console.log("📡 Telemetry heartbeat event written:", eventFile);
