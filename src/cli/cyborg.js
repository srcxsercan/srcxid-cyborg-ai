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
