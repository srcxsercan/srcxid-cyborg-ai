#!/usr/bin/env node
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const root = process.cwd();
const hbDir = path.join(root, "heartbeat");

if (!fs.existsSync(hbDir)) {
  console.error("❌ Heartbeat directory not found.");
  process.exit(1);
}

console.log("📈 Starship SLA Engine");

const files = fs.readdirSync(hbDir).filter(f => f.endsWith(".json"));

if (files.length === 0) {
  console.log("⚠️ No heartbeat data found.");
  process.exit(0);
}

let alive = 0;
let total = files.length;

for (const file of files) {
  const full = path.join(hbDir, file);
  try {
    const data = JSON.parse(fs.readFileSync(full, "utf8"));
    if (data.status === "alive") alive++;
  } catch {}
}

const sla = ((alive / total) * 100).toFixed(2);

console.log("✅ Services alive:", alive, "/", total);
console.log("❤️ SLA Score:", sla + "%");
