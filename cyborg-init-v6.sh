#!/bin/bash

echo "⚡ CYBORG-OS v6: AI-Driven Code Fixer başlatılıyor..."

mkdir -p src/fixer
mkdir -p .greptile

# === GREPTILE FIXER RULES ===
cat << 'G1' > .greptile/fixer.md
# CYBORG-OS v6 — AI-Driven Code Fixer Rules

Greptile bu projede:
- Naming convention hatalarını otomatik düzeltme önerisi üretmeli
- Folder structure yanlışsa öneri sunmalı
- Event pipeline eksikse patch önermeli
- Adapter interface uyumsuzluklarını tespit edip düzeltme önermeli
- Ledger kurallarına aykırı kodu işaretlemeli
- Retry / recovery mekanizması eksikse patch önermeli
- Kod kokularını (unused imports, dead code, long functions) tespit etmeli
G1

# === CODE SMELL DETECTOR ===
cat << 'SMELL' > src/fixer/smell-detector.js
export function detectSmells(code) {
  const smells = [];

  if (code.includes("console.log")) {
    smells.push("Remove console.log from production code");
  }

  if (code.includes("function") && code.length > 500) {
    smells.push("Function too long — consider splitting");
  }

  if (code.includes("var ")) {
    smells.push("Use let/const instead of var");
  }

  if (code.includes("TODO")) {
    smells.push("TODO found — ensure completion");
  }

  return smells;
}
SMELL

# === NAMING FIXER ===
cat << 'NAMEFIX' > src/fixer/naming-fixer.js
export function suggestNamingFix(filename) {
  const kebab = filename
    .replace(/([a-z])([A-Z])/g, "$1-$2")
    .toLowerCase();

  return {
    original: filename,
    suggested: kebab
  };
}
NAMEFIX

# === FOLDER STRUCTURE FIXER ===
cat << 'FOLDER' > src/fixer/folder-fixer.js
export function validateFolder(path) {
  const validRoots = ["core", "domain", "events", "utils", "adapters", "orchestrator"];
  const root = path.split("/")[1];

  if (!validRoots.includes(root)) {
    return {
      valid: false,
      message: "File is in the wrong folder — move to correct module"
    };
  }

  return { valid: true };
}
FOLDER

# === EVENT PIPELINE FIXER ===
cat << 'PIPEFIX' > src/fixer/event-fixer.js
export function fixEventPipeline(events) {
  const required = [
    "payment_requested",
    "payment_validated",
    "payment_routed",
    "payment_executed",
    "payment_settled"
  ];

  const missing = required.filter(e => !events.includes(e));

  return {
    missing,
    patch: missing.map(e => \`emitEvent("\${e}", payload);\`)
  };
}
PIPEFIX

# === CLI: CYBORG FIX ===
cat << 'CLI' > src/cli/cyborg-fix.js
#!/usr/bin/env node
import fs from "fs";
import { detectSmells } from "../fixer/smell-detector.js";
import { suggestNamingFix } from "../fixer/naming-fixer.js";
import { validateFolder } from "../fixer/folder-fixer.js";

const file = process.argv[2];
const code = fs.readFileSync(file, "utf8");

console.log("🔍 Smell Analysis:");
console.log(detectSmells(code));

console.log("\n🔧 Naming Suggestion:");
console.log(suggestNamingFix(file));

console.log("\n📁 Folder Validation:");
console.log(validateFolder(file));
CLI

chmod +x src/cli/cyborg-fix.js

echo "✅ CYBORG-OS v6 tamamlandı!"
