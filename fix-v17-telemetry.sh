#!/bin/bash

echo "📡 Fixing CYBORG-OS v17 Telemetry paths..."

# Auto-detect correct project root
if [ -d "src/cli" ]; then
  ROOT="."
elif [ -d "srcxid-cyborg-ai/src/cli" ]; then
  ROOT="srcxid-cyborg-ai"
else
  echo "❌ Could not detect project root. Run this from repo root."
  exit 1
fi

echo "✅ Project root detected: $ROOT"

mkdir -p $ROOT/telemetry/events
mkdir -p $ROOT/src/starship
mkdir -p $ROOT/src/cli

# === telemetry-config.json ===
cat << 'CFG' > $ROOT/src/starship/telemetry-config.json
{
  "sinks": {
    "file": {
      "enabled": true,
      "path": "telemetry/events"
    }
  },
  "services": [
    "nexus",
    "mesh",
    "lvm",
    "compliance",
    "multichain",
    "quantum",
    "orchestrator"
  ]
}
CFG

# === cyborg-telemetry-log.js ===
cat << 'LOG' > $ROOT/src/cli/cyborg-telemetry-log.js
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
LOG

# === cyborg-telemetry-report.js ===
cat << 'REP' > $ROOT/src/cli/cyborg-telemetry-report.js
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

const sinkDir = path.join(process.cwd(), cfg.sinks.file.path);
if (!fs.existsSync(sinkDir)) {
  console.error("❌ No telemetry events directory found:", sinkDir);
  process.exit(1);
}

const files = fs.readdirSync(sinkDir).filter(f => f.endsWith(".json"));

const perService = {};
let total = 0;

for (const file of files) {
  const fullPath = path.join(sinkDir, file);
  try {
    const data = JSON.parse(fs.readFileSync(fullPath, "utf8"));
    const svc = data.service || "unknown";
    perService[svc] = (perService[svc] || 0) + 1;
    total += 1;
  } catch {}
}

console.log("📊 Starship Telemetry Report");
console.log("Events directory:", sinkDir);
console.log("Total events:", total);
console.log("\nPer service:");
for (const svc of Object.keys(perService).sort()) {
  console.log("-", svc, ":", perService[svc]);
}
REP

chmod +x $ROOT/src/cli/cyborg-telemetry-log.js
chmod +x $ROOT/src/cli/cyborg-telemetry-report.js

echo "✅ Telemetry Core fixed and installed!"
