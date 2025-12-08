#!/usr/bin/env node
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const configPath = path.join(__dirname, "../starship/telemetry-config.json");
if (!fs.existsSync(configPath)) {
  console.error("❌ telemetry-config.json not found.");
  process.exit(1);
}

const cfg = JSON.parse(fs.readFileSync(configPath, "utf8"));

const sinkDir = path.join(process.cwd(), cfg.sinks.file.path);
if (!fs.existsSync(sinkDir)) {
  console.error("❌ No telemetry events directory found:", sinkDir);
  process.exit(1);
}

const files = fs.readdirSync(sinkDir).filter(f => f.endsWith(".json"));

const perService = {};
let total = 0;

for (const file of files) {
  const fullPath = path.join(sinkDir, file);
  try {
    const data = JSON.parse(fs.readFileSync(fullPath, "utf8"));
    const svc = data.service || "unknown";
    perService[svc] = (perService[svc] || 0) + 1;
    total += 1;
  } catch {
    // skip broken files silently
  }
}

console.log("📊 Starship Telemetry Report");
console.log("Events directory:", sinkDir);
console.log("Total events:", total);
console.log("\nPer service:");
for (const svc of Object.keys(perService).sort()) {
  console.log("-", svc, ":", perService[svc]);
}
