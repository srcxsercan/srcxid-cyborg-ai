#!/usr/bin/env node
import fs from "fs";
import path from "path";

const root = process.cwd();
const eventDir = path.join(root, "telemetry/events");

if (!fs.existsSync(eventDir)) fs.mkdirSync(eventDir, { recursive: true });

const ts = new Date().toISOString().replace(/[:.]/g, "-");
const eventFile = path.join(eventDir, `${ts}-v32-event.json`);

fs.writeFileSync(eventFile, JSON.stringify({
  version: "v32",
  timestamp: new Date().toISOString(),
  message: "Cyborg-OS v32 module installed successfully."
}, null, 2));

console.log("✅ v32 module installed.");
console.log("📡 Telemetry event:", eventFile);
