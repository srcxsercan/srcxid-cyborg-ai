#!/usr/bin/env node
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const eventDir = path.join(process.cwd(), "telemetry/events");

console.log("🚀 Starship Status Board");
console.log("Events directory:", eventDir);

if (!fs.existsSync(eventDir)) {
  console.log("❌ Telemetry directory not found.");
  process.exit(1);
}

const files = fs.readdirSync(eventDir).filter(f => f.endsWith(".json"));

if (files.length === 0) {
  console.log("⚠️ No telemetry events found.");
  process.exit(0);
}

let perService = {};
let lastEvent = null;

for (const file of files) {
  const full = path.join(eventDir, file);
  try {
    const data = JSON.parse(fs.readFileSync(full, "utf8"));
    const svc = data.service || "unknown";
    perService[svc] = (perService[svc] || 0) + 1;

    if (!lastEvent || data.timestamp > lastEvent.timestamp) {
      lastEvent = data;
    }
  } catch {}
}

console.log("\n📡 Event Count Per Service:");
for (const svc of Object.keys(perService).sort()) {
  console.log("-", svc, ":", perService[svc]);
}

console.log("\n⏱️ Last Event:");
console.log(lastEvent);

const total = files.length;
const health = Math.min(100, total * 5);

console.log("\n❤️ Starship Health Score:", health + "/100");
