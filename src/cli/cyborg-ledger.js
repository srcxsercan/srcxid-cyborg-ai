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
