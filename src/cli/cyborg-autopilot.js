#!/usr/bin/env node
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

console.log("✅ CLI stabilized and running:", __filename);

// Telemetry event
try {
  const eventDir = path.join(process.cwd(), "telemetry/events");
  if (!fs.existsSync(eventDir)) fs.mkdirSync(eventDir, { recursive: true });

  const ts = new Date().toISOString().replace(/[:.]/g, "-");
  const fileName = path.join(eventDir, `${ts}-stabilized.json`);

  fs.writeFileSync(
    fileName,
    JSON.stringify({ cli: __filename, timestamp: new Date().toISOString() }, null, 2)
  );
} catch (e) {
  console.log("⚠️ Telemetry yazılamadı:", e.message);
}
