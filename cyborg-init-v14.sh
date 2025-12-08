#!/bin/bash

echo "🚀 CYBORG-OS v14: SRCX Starship OS manifest oluşturuluyor..."

mkdir -p src/starship
mkdir -p src/cli

# === STARSHIP MANIFEST ===
cat << 'MNF' > src/starship/manifest.json
{
  "name": "SRCX Starship OS",
  "version": "v14",
  "layers": {
    "bootstrap": ["v1", "v2"],
    "self_generating": ["v3"],
    "orchestrator": ["v4"],
    "recovery": ["v5"],
    "fixer": ["v6"],
    "routing_brain": ["v7"],
    "ledger_vm": ["v8"],
    "compliance": ["v9"],
    "nexus": ["v10"],
    "mesh": ["v11"],
    "multichain": ["v12"],
    "quantum": ["v13"]
  },
  "capabilities": {
    "self_healing": true,
    "policy_driven": true,
    "multi_provider": true,
    "multi_chain": true,
    "distributed": true,
    "quantum_inspired": true
  }
}
MNF

# === CYBORG ABOUT CLI ===
cat << 'ABOUT' > src/cli/cyborg-about.js
#!/usr/bin/env node
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const manifestPath = path.join(__dirname, "../starship/manifest.json");
const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));

console.log("🚀", manifest.name);
console.log("Version:", manifest.version);

console.log("\nLayers:");
for (const [layer, versions] of Object.entries(manifest.layers)) {
  console.log("-", layer, "=>", versions.join(", "));
}

console.log("\nCapabilities:");
for (const [key, val] of Object.entries(manifest.capabilities)) {
  console.log("-", key, ":", val ? "ENABLED" : "DISABLED");
}
ABOUT

chmod +x src/cli/cyborg-about.js

echo "✅ CYBORG-OS v14 (Starship OS manifest + cyborg-about) tamamlandı!"
