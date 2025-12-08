#!/usr/bin/env node
import fs from "fs";
import path from "path";
import crypto from "crypto";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const root = process.cwd();

const stateDir = path.join(root, "sync/state");
const hbDir = path.join(root, "heartbeat");
const eventDir = path.join(root, "telemetry/events");

console.log("🧠 Starship Brain 2.0 — Unified Decision Engine");

// === LOAD STATE ===
function loadJSON(dir) {
  if (!fs.existsSync(dir)) return {};
  const files = fs.readdirSync(dir).filter(f => f.endsWith(".json"));
  let out = {};
  for (const f of files) {
    try {
      out[f] = JSON.parse(fs.readFileSync(path.join(dir, f), "utf8"));
    } catch {}
  }
  return out;
}

const states = loadJSON(stateDir);
const heartbeats = loadJSON(hbDir);

// === RISK SCORE ===
function calculateRisk(states, heartbeats) {
  let score = 0;

  // Node count
  const nodeCount = Object.keys(states).length;
  if (nodeCount < 1) score += 50;
  if (nodeCount > 3) score -= 10;

  // Heartbeat freshness
  for (const hb of Object.values(heartbeats)) {
    const age = Date.now() - new Date(hb.timestamp).getTime();
    if (age > 60000) score += 20;
  }

  // Random entropy (quantum-like)
  score += Math.floor(Math.random() * 10);

  return Math.max(0, Math.min(100, score));
}

const risk = calculateRisk(states, heartbeats);

// === DECISION LOGIC ===
let decision = "REVIEW";

if (risk < 30) decision = "APPROVE";
else if (risk > 70) decision = "DENY";

// === QUANTUM OVERRIDE ===
const quantumOverride = Math.random() < 0.05; // 5% chance

if (quantumOverride) {
  const options = ["APPROVE", "DENY", "REVIEW"];
  decision = options[Math.floor(Math.random() * options.length)];
  console.log("⚛️ Quantum override triggered!");
}

console.log("📊 Risk Score:", risk);
console.log("✅ Final Decision:", decision);

// === WRITE TELEMETRY EVENT ===
if (!fs.existsSync(eventDir)) fs.mkdirSync(eventDir, { recursive: true });

const ts = new Date().toISOString().replace(/[:.]/g, "-");
const eventFile = path.join(eventDir, `${ts}-decision.json`);

fs.writeFileSync(eventFile, JSON.stringify({
  type: "decision",
  timestamp: new Date().toISOString(),
  risk,
  decision,
  quantumOverride
}, null, 2));

console.log("📡 Decision event written:", eventFile);
