#!/usr/bin/env node
import fs from "fs";
import path from "path";

const root = process.cwd();
const txDir = path.join(root, "transactions");
const eventDir = path.join(root, "telemetry/events");

if (!fs.existsSync(eventDir)) fs.mkdirSync(eventDir, { recursive: true });

const queueFile = path.join(txDir, "queue.json");
const historyFile = path.join(txDir, "history.json");

function loadJSON(file, fallback) {
  if (!fs.existsSync(file)) return fallback;
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch {
    return fallback;
  }
}

function saveJSON(file, data) {
  fs.writeFileSync(file, JSON.stringify(data, null, 2));
}

let queue = loadJSON(queueFile, []);
let history = loadJSON(historyFile, []);

function emitEvent(payload) {
  const ts = new Date().toISOString().replace(/[:.]/g, "-");
  const eventFile = path.join(eventDir, ts + "-tx-event.json");
  fs.writeFileSync(eventFile, JSON.stringify(payload, null, 2));
  console.log("📡 Tx event:", eventFile);
}

console.log("💳 Cyborg Transaction CLI");

const tx = {
  id: "TX-" + new Date().toISOString().replace(/[:.]/g, "-"),
  amount: 10,
  currency: "USD",
  country: "US",
  status: "CREATED",
  steps: []
};

queue.push(tx);
emitEvent({ type: "tx_created", tx });

tx.status = "AUTHORIZED";
tx.steps.push({ step: "authorize", ts: new Date().toISOString() });
emitEvent({ type: "tx_authorized", tx });

tx.status = "CAPTURED";
tx.steps.push({ step: "capture", ts: new Date().toISOString() });
emitEvent({ type: "tx_captured", tx });

tx.status = "SETTLED";
tx.steps.push({ step: "settle", ts: new Date().toISOString() });
emitEvent({ type: "tx_settled", tx });

history.push(tx);
queue = queue.filter(t => t.id !== tx.id);

saveJSON(queueFile, queue);
saveJSON(historyFile, history);

console.log("✅ Transaction test akışı tamamlandı.");
