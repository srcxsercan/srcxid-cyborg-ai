#!/bin/bash

echo "🚀 SRCX Starship Core + Kernel Setup başlıyor..."
ROOT=$(pwd)

# Klasör yapısı
mkdir -p \
  "$ROOT/src/cli" \
  "$ROOT/ledger" \
  "$ROOT/transactions" \
  "$ROOT/routing" \
  "$ROOT/kernel" \
  "$ROOT/sync/state" \
  "$ROOT/heartbeat" \
  "$ROOT/memory/snapshots" \
  "$ROOT/telemetry/events"

echo "📁 Klasörler hazır."

# === Ledger Initial Data ===
if [ ! -f "$ROOT/ledger/accounts.json" ]; then
  cat << 'JSON' > "$ROOT/ledger/accounts.json"
[
  {
    "id": "ACC-1000",
    "name": "SRCX Master Settlement",
    "currency": "USD",
    "balance": 0
  }
]
JSON
  echo "✅ ledger/accounts.json oluşturuldu."
fi

if [ ! -f "$ROOT/ledger/journal.json" ]; then
  cat << 'JSON' > "$ROOT/ledger/journal.json"
[]
JSON
  echo "✅ ledger/journal.json oluşturuldu."
fi

# === Transactions Initial Data ===
if [ ! -f "$ROOT/transactions/queue.json" ]; then
  cat << 'JSON' > "$ROOT/transactions/queue.json"
[]
JSON
  echo "✅ transactions/queue.json oluşturuldu."
fi

if [ ! -f "$ROOT/transactions/history.json" ]; then
  cat << 'JSON' > "$ROOT/transactions/history.json"
[]
JSON
  echo "✅ transactions/history.json oluşturuldu."
fi

# === Routing Initial Data ===
if [ ! -f "$ROOT/routing/providers.json" ]; then
  cat << 'JSON' > "$ROOT/routing/providers.json"
[
  {
    "id": "PROV-STRIPE",
    "name": "Stripe",
    "countries": ["US", "CA", "GB"],
    "currencies": ["USD", "CAD", "GBP"],
    "riskScore": 20
  },
  {
    "id": "PROV-ADYEN",
    "name": "Adyen",
    "countries": ["NL", "DE", "FR", "GB"],
    "currencies": ["EUR", "GBP"],
    "riskScore": 25
  },
  {
    "id": "PROV-LOCAL-TR",
    "name": "Local Bank TR",
    "countries": ["TR"],
    "currencies": ["TRY"],
    "riskScore": 15
  }
]
JSON
  echo "✅ routing/providers.json oluşturuldu."
fi

if [ ! -f "$ROOT/routing/routes.json" ]; then
  cat << 'JSON' > "$ROOT/routing/routes.json"
[]
JSON
  echo "✅ routing/routes.json oluşturuldu."
fi

# === LEDGER CLI ===
cat << 'JS' > "$ROOT/src/cli/cyborg-ledger.js"
#!/usr/bin/env node
import fs from "fs";
import path from "path";

const root = process.cwd();
const ledgerDir = path.join(root, "ledger");
const eventDir = path.join(root, "telemetry/events");

if (!fs.existsSync(eventDir)) fs.mkdirSync(eventDir, { recursive: true });

const accountsFile = path.join(ledgerDir, "accounts.json");
const journalFile = path.join(ledgerDir, "journal.json");

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

let accounts = loadJSON(accountsFile, []);
let journal = loadJSON(journalFile, []);

function findAccount(id) {
  return accounts.find(a => a.id === id);
}

function ensureAccount(id, name, currency) {
  let acc = findAccount(id);
  if (!acc) {
    acc = { id, name, currency, balance: 0 };
    accounts.push(acc);
  }
  return acc;
}

function postJournalEntry({ debit, credit, amount, currency, meta }) {
  const ts = new Date().toISOString();
  journal.push({
    id: "JNL-" + ts.replace(/[:.]/g, "-"),
    timestamp: ts,
    debit,
    credit,
    amount,
    currency,
    meta
  });

  const debitAcc = ensureAccount(debit, debit, currency);
  const creditAcc = ensureAccount(credit, credit, currency);

  debitAcc.balance += amount;
  creditAcc.balance -= amount;
}

function emitEvent(payload) {
  const ts = new Date().toISOString().replace(/[:.]/g, "-");
  const eventFile = path.join(eventDir, ts + "-ledger-event.json");
  fs.writeFileSync(eventFile, JSON.stringify(payload, null, 2));
  console.log("📡 Ledger event:", eventFile);
}

console.log("💰 Cyborg Ledger CLI");

postJournalEntry({
  debit: "ACC-1000",
  credit: "ACC-EXTERNAL",
  amount: 100,
  currency: "USD",
  meta: { reason: "test_credit" }
});

saveJSON(accountsFile, accounts);
saveJSON(journalFile, journal);

emitEvent({
  type: "ledger_journal_posted",
  timestamp: new Date().toISOString(),
  amount: 100,
  currency: "USD",
  debit: "ACC-1000",
  credit: "ACC-EXTERNAL"
});

console.log("✅ Ledger test journal işlendi.");
JS
chmod +x "$ROOT/src/cli/cyborg-ledger.js"
echo "✅ cyborg-ledger.js yazıldı."

# === ROUTING CLI ===
cat << 'JS' > "$ROOT/src/cli/cyborg-routing.js"
#!/usr/bin/env node
import fs from "fs";
import path from "path";

const root = process.cwd();
const routingDir = path.join(root, "routing");
const eventDir = path.join(root, "telemetry/events");

if (!fs.existsSync(eventDir)) fs.mkdirSync(eventDir, { recursive: true });

const providersFile = path.join(routingDir, "providers.json");
const routesFile = path.join(routingDir, "routes.json");

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

const providers = loadJSON(providersFile, []);
let routes = loadJSON(routesFile, []);

function chooseProvider({ amount, currency, country, mcc }) {
  let candidates = providers.filter(p =>
    p.currencies.includes(currency) &&
    p.countries.includes(country)
  );

  if (candidates.length === 0) candidates = providers;

  candidates.sort((a, b) => a.riskScore - b.riskScore);
  return candidates[0] || null;
}

function emitEvent(payload) {
  const ts = new Date().toISOString().replace(/[:.]/g, "-");
  const eventFile = path.join(eventDir, ts + "-routing-event.json");
  fs.writeFileSync(eventFile, JSON.stringify(payload, null, 2));
  console.log("📡 Routing event:", eventFile);
}

console.log("🛰️ Cyborg Routing CLI");

const testTx = {
  id: "TX-ROUTE-TEST",
  amount: 42,
  currency: "USD",
  country: "US",
  mcc: "5732"
};

const provider = chooseProvider(testTx);

const route = {
  id: "ROUTE-" + testTx.id,
  timestamp: new Date().toISOString(),
  tx: testTx,
  provider: provider ? provider.id : null
};

routes.push(route);
saveJSON(routesFile, routes);

emitEvent({
  type: "routing_decision",
  timestamp: new Date().toISOString(),
  tx: testTx,
  provider
});

console.log("✅ Routing test kararı üretildi.");
JS
chmod +x "$ROOT/src/cli/cyborg-routing.js"
echo "✅ cyborg-routing.js yazıldı."

# === TRANSACTION CLI ===
cat << 'JS' > "$ROOT/src/cli/cyborg-tx.js"
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
JS
chmod +x "$ROOT/src/cli/cyborg-tx.js"
echo "✅ cyborg-tx.js yazıldı."

# === KERNEL CLI (Autonomous Check) ===
cat << 'JS' > "$ROOT/src/cli/cyborg-kernel.js"
#!/usr/bin/env node
import fs from "fs";
import path from "path";

const root = process.cwd();

const teleDir = path.join(root, "telemetry/events");
const hbDir = path.join(root, "heartbeat");
const snapDir = path.join(root, "memory/snapshots");
const stateDir = path.join(root, "sync/state");

function countFiles(dir) {
  if (!fs.existsSync(dir)) return 0;
  return fs.readdirSync(dir).filter(f => f.endsWith(".json")).length;
}

console.log("🧬 Cyborg Kernel — Autonomous Check");

const telemetryCount = countFiles(teleDir);
const hbCount = countFiles(hbDir);
const snapCount = countFiles(snapDir);
const stateCount = countFiles(stateDir);

let actions = [];

if (hbCount === 0) {
  actions.push("heartbeat_missing");
}

if (snapCount === 0) {
  actions.push("create_snapshot");
}

if (stateCount === 0) {
  actions.push("request_sync");
}

let healthScore = 100;
if (telemetryCount === 0) healthScore -= 20;
if (hbCount === 0) healthScore -= 20;
if (snapCount === 0) healthScore -= 20;
if (stateCount === 0) healthScore -= 20;

console.log("📊 Kernel Health Score:", healthScore);
console.log("🧩 Suggested Actions:", actions);

const kernelDir = path.join(root, "kernel");
if (!fs.existsSync(kernelDir)) fs.mkdirSync(kernelDir, { recursive: true });

const reportFile = path.join(kernelDir, "kernel-autonomous-report.json");
fs.writeFileSync(reportFile, JSON.stringify({
  timestamp: new Date().toISOString(),
  telemetryCount,
  hbCount,
  snapCount,
  stateCount,
  healthScore,
  actions
}, null, 2));

console.log("📄 Kernel report:", reportFile);
JS
chmod +x "$ROOT/src/cli/cyborg-kernel.js"
echo "✅ cyborg-kernel.js yazıldı."

echo "▶️ Test akışı başlatılıyor..."

if [ -f "$ROOT/src/cli/cyborg-ledger.js" ]; then
  node "$ROOT/src/cli/cyborg-ledger.js"
fi

if [ -f "$ROOT/src/cli/cyborg-routing.js" ]; then
  node "$ROOT/src/cli/cyborg-routing.js"
fi

if [ -f "$ROOT/src/cli/cyborg-tx.js" ]; then
  node "$ROOT/src/cli/cyborg-tx.js"
fi

if [ -f "$ROOT/src/cli/cyborg-brain.js" ]; then
  node "$ROOT/src/cli/cyborg-brain.js"
fi

if [ -f "$ROOT/src/cli/cyborg-rc.js" ]; then
  node "$ROOT/src/cli/cyborg-rc.js"
fi

node "$ROOT/src/cli/cyborg-kernel.js"

echo "✅ SRCX Starship Core + Kernel setup tamamlandı."
