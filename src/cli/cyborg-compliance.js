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
