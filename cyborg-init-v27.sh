#!/bin/bash
echo "🚀 CYBORG-OS v27 Installer çalışıyor..."

ROOT=$(pwd)

mkdir -p $ROOT/src/cli
mkdir -p $ROOT/sync/state
mkdir -p $ROOT/heartbeat
mkdir -p $ROOT/memory/snapshots
mkdir -p $ROOT/telemetry/events

# === CLI ===
cat << 'JS' > $ROOT/src/cli/cyborg-v27.js
#!/usr/bin/env node
import fs from "fs";
import path from "path";

const root = process.cwd();
const eventDir = path.join(root, "telemetry/events");

if (!fs.existsSync(eventDir)) fs.mkdirSync(eventDir, { recursive: true });

const ts = new Date().toISOString().replace(/[:.]/g, "-");
const eventFile = path.join(eventDir, `${ts}-v27-event.json`);

fs.writeFileSync(eventFile, JSON.stringify({
  version: "v27",
  timestamp: new Date().toISOString(),
  message: "Cyborg-OS v27 module installed successfully."
}, null, 2));

console.log("✅ v27 module installed.");
console.log("📡 Telemetry event:", eventFile);
JS

chmod +x $ROOT/src/cli/cyborg-v27.js

echo "✅ CYBORG-OS v27 Installer tamamlandı!"
