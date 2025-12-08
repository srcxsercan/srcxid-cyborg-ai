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
