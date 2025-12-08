#!/bin/bash

echo "⚡ CYBORG-OS v9: Autonomous Compliance Engine başlatılıyor..."

mkdir -p src/compliance
mkdir -p src/compliance/policies
mkdir -p src/compliance/runtime
mkdir -p .greptile

# === GREPTILE COMPLIANCE RULES ===
cat << 'G1' > .greptile/compliance.md
# CYBORG-OS v9 — Autonomous Compliance Engine Rules

Greptile bu projede:
- AML / Fraud / Risk kurallarının policy dosyalarından okunduğunu doğrulamalı
- Velocity checks, anomaly detection ve pattern matching kurallarını kontrol etmeli
- Suspicious activity detection engine'in doğru çalıştığını doğrulamalı
- Compliance kararlarının event pipeline'a bağlandığını doğrulamalı
- Policy dosyalarındaki hataları işaretlemeli
G1

# === COMPLIANCE POLICY FORMAT ===
cat << 'POLICY' > src/compliance/policies/default.json
{
  "rules": {
    "velocity": {
      "max_amount_per_minute": 5000,
      "max_transactions_per_hour": 20
    },
    "anomaly": {
      "sudden_spike_threshold": 3.0
    },
    "patterns": [
      "amount > 10000 && country == 'HIGH_RISK'",
      "currency == 'USDT' && amount > 5000"
    ]
  }
}
POLICY

# === POLICY LOADER ===
cat << 'LOAD' > src/compliance/runtime/policy-loader.js
import fs from "fs";

export function loadCompliancePolicy(name = "default") {
  const raw = fs.readFileSync(\`src/compliance/policies/\${name}.json\`, "utf8");
  return JSON.parse(raw);
}
LOAD

# === VELOCITY CHECK ENGINE ===
cat << 'VEL' > src/compliance/runtime/velocity.js
export function velocityCheck(policy, history, payload) {
  const lastMinute = history.filter(t => Date.now() - t.timestamp < 60000);
  const lastHour = history.filter(t => Date.now() - t.timestamp < 3600000);

  if (lastMinute.reduce((a, t) => a + t.amount, 0) + payload.amount >
      policy.rules.velocity.max_amount_per_minute) {
    return "Velocity breach: amount per minute exceeded";
  }

  if (lastHour.length + 1 > policy.rules.velocity.max_transactions_per_hour) {
    return "Velocity breach: too many transactions per hour";
  }

  return null;
}
VEL

# === ANOMALY DETECTION ENGINE ===
cat << 'ANO' > src/compliance/runtime/anomaly.js
export function anomalyScore(policy, history, payload) {
  const avg = history.reduce((a, t) => a + t.amount, 0) / (history.length || 1);
  const spike = payload.amount / (avg || 1);

  if (spike >= policy.rules.anomaly.sudden_spike_threshold) {
    return "Anomaly detected: sudden spike in transaction amount";
  }

  return null;
}
ANO

# === PATTERN MATCHING ENGINE ===
cat << 'PAT' > src/compliance/runtime/patterns.js
export function patternMatch(policy, payload) {
  for (const rule of policy.rules.patterns) {
    const expr = rule
      .replace("amount", payload.amount)
      .replace("country", \`"\${payload.country}"\`)
      .replace("currency", \`"\${payload.currency}"\`);

    if (eval(expr)) {
      return \`Pattern match triggered: \${rule}\`;
    }
  }
  return null;
}
PAT

# === COMPLIANCE CORE ENGINE ===
cat << 'CORE' > src/compliance/compliance-core.js
import { loadCompliancePolicy } from "./runtime/policy-loader.js";
import { velocityCheck } from "./runtime/velocity.js";
import { anomalyScore } from "./runtime/anomaly.js";
import { patternMatch } from "./runtime/patterns.js";

export class ComplianceEngine {
  constructor(history = [], policyName = "default") {
    this.history = history;
    this.policy = loadCompliancePolicy(policyName);
  }

  evaluate(payload) {
    const checks = [
      velocityCheck(this.policy, this.history, payload),
      anomalyScore(this.policy, this.history, payload),
      patternMatch(this.policy, payload)
    ];

    const issues = checks.filter(Boolean);

    if (issues.length > 0) {
      return {
        status: "FLAGGED",
        issues
      };
    }

    return {
      status: "CLEAR"
    };
  }
}
CORE

# === CLI: COMPLIANCE TEST ===
cat << 'CLI' > src/cli/cyborg-compliance.js
#!/usr/bin/env node
import { ComplianceEngine } from "../compliance/compliance-core.js";

const engine = new ComplianceEngine([
  { amount: 100, timestamp: Date.now() - 10000 },
  { amount: 200, timestamp: Date.now() - 20000 }
]);

const result = engine.evaluate({
  amount: 6000,
  currency: "USDT",
  country: "HIGH_RISK"
});

console.log("✅ Compliance Test Result:");
console.log(JSON.stringify(result, null, 2));
CLI

chmod +x src/cli/cyborg-compliance.js

echo "✅ CYBORG-OS v9 tamamlandı!"
