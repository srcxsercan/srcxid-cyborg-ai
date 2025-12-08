#!/usr/bin/env node
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const configPath = path.join(__dirname, "../starship/telemetry-config.json");
if (!fs.existsSync(configPath)) {
  console.error("❌ telemetry-config.json not found.");
  process.exit(1);
}

const cfg = JSON.parse(fs.readFileSync(configPath, "utf8"));

const service = process.argv[2];
const rawPayload = process.argv[3];

if (!service || !rawPayload) {
  console.error("Usage: cyborg-telemetry-log <service> '<json-payload>'");
  process.exit(1);
}

if (!cfg.services.includes(service)) {
  console.error("❌ Unknown service:", service);
  console.log("Known services:", cfg.services.join(", "));
  process.exit(1);
}

let payload;
try {
  payload = JSON.parse(rawPayload);
} catch (e) {
  console.error("❌ Invalid JSON payload:", e.message);
  process.exit(1);
}

if (!cfg.sinks.file?.enabled) {
  console.error("❌ File sink not enabled in telemetry-config.");
  process.exit(1);
}

const sinkDir = path.join(process.cwd(), cfg.sinks.file.path);
if (!fs.existsSync(sinkDir)) fs.mkdirSync(sinkDir, { recursive: true });

const ts = new Date().toISOString().replace(/[:.]/g, "-");
const fileName = path.join(sinkDir, `${ts}-${service}.json`);

const event = {
  service,
  timestamp: new Date().toISOString(),
  payload
};

fs.writeFileSync(fileName, JSON.stringify(event, null, 2), "utf8");

console.log("📡 Telemetry event written:", fileName);
