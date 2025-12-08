#!/usr/bin/env node
import fs from "fs";
import path from "path";
import crypto from "crypto";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const root = process.cwd();
const hashFile = path.join(root, "src/starship/guardian-hashes.json");
const eventDir = path.join(root, "telemetry/events");

if (!fs.existsSync(hashFile)) {
  console.error("❌ Guardian hash manifest bulunamadı.");
  process.exit(1);
}

const manifest = JSON.parse(fs.readFileSync(hashFile, "utf8"));

console.log("🛡️ Starship Guardian — Intrusion Detection");
console.log("Hash manifest loaded:", hashFile);

const cliDir = path.join(root, "src/cli");
const files = fs.readdirSync(cliDir).filter(f => f.endsWith(".js"));

let issues = [];

for (const file of files) {
  const full = path.join(cliDir, file);
  const content = fs.readFileSync(full);
  const hash = crypto.createHash("sha256").update(content).digest("hex");

  if (!manifest[file]) {
    issues.push({ type: "unknown_cli", file });
    continue;
  }

  if (manifest[file] !== hash) {
    issues.push({ type: "tampered", file, expected: manifest[file], actual: hash });
  }
}

if (issues.length === 0) {
  console.log("✅ No security issues detected.");
  process.exit(0);
}

console.log("❌ Security issues detected:");
console.log(JSON.stringify(issues, null, 2));

// Write telemetry event
if (!fs.existsSync(eventDir)) fs.mkdirSync(eventDir, { recursive: true });

const ts = new Date().toISOString().replace(/[:.]/g, "-");
const eventFile = path.join(eventDir, `${ts}-security.json`);

fs.writeFileSync(eventFile, JSON.stringify({
  type: "security_alert",
  timestamp: new Date().toISOString(),
  issues
}, null, 2));

console.log("📡 Security event written:", eventFile);
