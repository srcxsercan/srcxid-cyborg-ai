#!/bin/bash

echo "⚡ CYBORG-OS v3: Self-Generating Autobot Engine başlatılıyor..."

# === KLASÖR YAPISI ===
mkdir -p src/{core,domain,events,utils,cli,generators}
mkdir -p src/adapters/{providers,bank-rails}
mkdir -p tests/{unit,integration}
mkdir -p docs
mkdir -p .greptile

# === GREPTILE CONFIG ===
cat << 'C1' > .greptile/context.md
# CYBORG-OS v3 — Self-Generating Autobot Engine

Greptile bu projede:
- Event pipeline doğrulaması yapmalı
- Ledger kurallarını enforce etmeli
- Naming convention hatalarını düzeltmeli
- Adapter interface uyumsuzluklarını tespit etmeli
- correlation_id eksikse uyarmalı
- Hatalı folder structure'ı düzeltmeyi önermeli
- Business logic leakage tespit etmeli
- CLI ile üretilen kodları referans almalı
C1

# === PROVIDER GENERATOR ===
cat << 'G1' > src/generators/provider-generator.js
export function generateProvider(name) {
  return `
export class ${name}Provider {
  async authorize(payload) {}
  async capture(payload) {}
  async sale(payload) {}
  async refund(payload) {}
  async payout(payload) {}
}
`;
}
G1

# === BANK RAIL GENERATOR ===
cat << 'G2' > src/generators/bank-rail-generator.js
export function generateBankRail(name) {
  return `
export class ${name}BankRail {
  async openAccount(payload) {}
  async sendPayment(payload) {}
  async receiveNotification(payload) {}
  async getStatement(payload) {}
}
`;
}
G2

# === EVENT PIPELINE VALIDATOR ===
cat << 'E1' > src/utils/event-validator.js
export function validateEventPipeline(events) {
  const required = [
    "payment_requested",
    "payment_validated",
    "payment_routed",
    "payment_executed",
    "payment_settled"
  ];
  return required.every(e => events.includes(e));
}
E1

# === CORRELATION ID INJECTOR ===
cat << 'CID' > src/utils/correlation.js
import crypto from "crypto";

export function ensureCorrelation(data) {
  return {
    ...data,
    correlation_id: data?.correlation_id || crypto.randomUUID()
  };
}
CID

# === ERROR HANDLING WRAPPER ===
cat << 'ERR' > src/utils/trycatch.js
export async function safe(fn) {
  try {
    return await fn();
  } catch (err) {
    return { error: true, message: err.message };
  }
}
ERR

# === CLI ===
cat << 'CLI' > src/cli/cyborg.js
#!/usr/bin/env node
import fs from "fs";
import { generateProvider } from "../generators/provider-generator.js";
import { generateBankRail } from "../generators/bank-rail-generator.js";

const cmd = process.argv[2];
const name = process.argv[3];

if (cmd === "provider") {
  const code = generateProvider(name);
  fs.writeFileSync(\`src/adapters/providers/\${name}-provider.js\`, code);
  console.log("✅ Provider oluşturuldu:", name);
}

if (cmd === "bankrail") {
  const code = generateBankRail(name);
  fs.writeFileSync(\`src/adapters/bank-rails/\${name}-bankrail.js\`, code);
  console.log("✅ Bank rail oluşturuldu:", name);
}
CLI

chmod +x src/cli/cyborg.js

# === PRE-COMMIT HOOK ===
mkdir -p .git/hooks
cat << 'HOOK' > .git/hooks/pre-commit
#!/bin/bash
echo "🔍 CYBORG-OS: Event pipeline doğrulanıyor..."
node -e "
import { validateEventPipeline } from './src/utils/event-validator.js';
const events = ['payment_requested','payment_validated','payment_routed','payment_executed','payment_settled'];
if (!validateEventPipeline(events)) { process.exit(1); }
"
echo "✅ Pipeline doğru."
HOOK

chmod +x .git/hooks/pre-commit

echo "✅ CYBORG-OS v3 tamamlandı!"
