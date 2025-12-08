#!/bin/bash

echo "🤖 CYBORG-OS Installer Generator — v26 → v50"
ROOT=$(pwd)

mkdir -p src/cli
mkdir -p telemetry/events

generate_installer() {
  local v=$1
  local script="cyborg-init-v${v}.sh"

  cat << EOS > $script
#!/bin/bash
echo "🚀 CYBORG-OS v${v} Installer çalışıyor..."

ROOT=\$(pwd)

mkdir -p \$ROOT/src/cli
mkdir -p \$ROOT/sync/state
mkdir -p \$ROOT/heartbeat
mkdir -p \$ROOT/memory/snapshots
mkdir -p \$ROOT/telemetry/events

# === CLI ===
cat << 'JS' > \$ROOT/src/cli/cyborg-v${v}.js
#!/usr/bin/env node
import fs from "fs";
import path from "path";

const root = process.cwd();
const eventDir = path.join(root, "telemetry/events");

if (!fs.existsSync(eventDir)) fs.mkdirSync(eventDir, { recursive: true });

const ts = new Date().toISOString().replace(/[:.]/g, "-");
const eventFile = path.join(eventDir, \`\${ts}-v${v}-event.json\`);

fs.writeFileSync(eventFile, JSON.stringify({
  version: "v${v}",
  timestamp: new Date().toISOString(),
  message: "Cyborg-OS v${v} module installed successfully."
}, null, 2));

console.log("✅ v${v} module installed.");
console.log("📡 Telemetry event:", eventFile);
JS

chmod +x \$ROOT/src/cli/cyborg-v${v}.js

echo "✅ CYBORG-OS v${v} Installer tamamlandı!"
EOS

  chmod +x $script
  echo "✅ v${v} installer üretildi."
}

for v in {26..50}; do
  generate_installer $v
done

echo "✅ Tüm installer'lar üretildi."
