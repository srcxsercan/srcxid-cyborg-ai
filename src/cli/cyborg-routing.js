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
