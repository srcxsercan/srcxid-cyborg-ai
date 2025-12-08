#!/bin/bash

echo "🚀 CYBORG-OS v25: Starship OS Release Candidate kuruluyor..."

ROOT=$(pwd)

# Required directories
DIRS=(
  "src/cli"
  "sync/state"
  "heartbeat"
  "memory/snapshots"
  "telemetry/events"
)

echo "📁 Klasör yapısı doğrulanıyor..."
for d in "${DIRS[@]}"; do
  if [ ! -d "$ROOT/$d" ]; then
    echo "❌ Eksik klasör: $d — oluşturuluyor..."
    mkdir -p "$ROOT/$d"
  else
    echo "✅ $d mevcut"
  fi
done

# === RC REPORT CLI ===
cat << 'JS' > $ROOT/src/cli/cyborg-rc.js
#!/usr/bin/env node
import fs from "fs";
import path from "path";

const root = process.cwd();

function countFiles(dir) {
  if (!fs.existsSync(dir)) return 0;
  return fs.readdirSync(dir).filter(f => f.endsWith(".json")).length;
}

console.log("🚀 Starship OS v25 — Release Candidate Report");

const telemetryCount = countFiles(path.join(root, "telemetry/events"));
const stateCount = countFiles(path.join(root, "sync/state"));
const snapshotCount = countFiles(path.join(root, "memory/snapshots"));
const heartbeatCount = countFiles(path.join(root, "heartbeat"));

console.log("\n📊 Component Status:");
console.log("- Telemetry events:", telemetryCount);
console.log("- Sync states:", stateCount);
console.log("- Snapshots:", snapshotCount);
console.log("- Heartbeats:", heartbeatCount);

// Health score
let score = 100;

if (telemetryCount < 1) score -= 20;
if (stateCount < 1) score -= 20;
if (snapshotCount < 1) score -= 20;
if (heartbeatCount < 1) score -= 20;

console.log("\n❤️ Final Health Score:", score + "/100");

const rcFile = path.join(root, "starship-rc-report.json");
fs.writeFileSync(rcFile, JSON.stringify({
  version: "v25",
  timestamp: new Date().toISOString(),
  telemetryCount,
  stateCount,
  snapshotCount,
  heartbeatCount,
  healthScore: score
}, null, 2));

console.log("\n📄 RC Report written:", rcFile);
JS

chmod +x $ROOT/src/cli/cyborg-rc.js

echo "✅ CYBORG-OS v25 Release Candidate tamamlandı!"
