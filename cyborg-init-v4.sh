#!/bin/bash

echo "⚡ CYBORG-OS v4: Core Orchestrator Engine başlatılıyor..."

mkdir -p src/{core,domain,events,utils,cli,generators,orchestrator}
mkdir -p src/adapters/{providers,bank-rails}
mkdir -p src/queue
mkdir -p tests/{unit,integration}
mkdir -p .greptile

# === GREPTILE ORCHESTRATOR RULES ===
cat << 'G1' > .greptile/orchestrator.md
# CYBORG-OS v4 — Orchestrator Rules

Greptile bu projede:
- Event pipeline state machine uyumluluğunu kontrol etmeli
- Orchestrator'ın provider ve bank-rail adapter'larını doğru bağladığını doğrulamalı
- Transaction engine'in double-entry ledger kurallarına uyduğunu kontrol etmeli
- Routing engine'in MCC, country, provider-availability kurallarına uyduğunu doğrulamalı
- Queue mekanizmasının retry + backoff içerdiğini kontrol etmeli
- Error recovery mekanizmasını enforce etmeli
G1

# === EVENT BUS ===
cat << 'EBUS' > src/queue/event-bus.js
export class EventBus {
  constructor() {
    this.queue = [];
  }

  publish(event) {
    this.queue.push(event);
  }

  consume(handler) {
    while (this.queue.length > 0) {
      const event = this.queue.shift();
      handler(event);
    }
  }
}
EBUS

# === STATE MACHINE PIPELINE ===
cat << 'SM1' > src/orchestrator/state-machine.js
export const PipelineStates = {
  REQUESTED: "payment_requested",
  VALIDATED: "payment_validated",
  ROUTED: "payment_routed",
  EXECUTED: "payment_executed",
  SETTLED: "payment_settled"
};

export function nextState(current) {
  const order = Object.values(PipelineStates);
  const index = order.indexOf(current);
  return order[index + 1] || null;
}
SM1

# === TRANSACTION ENGINE ===
cat << 'TE1' > src/orchestrator/transaction-engine.js
import { nextState } from "./state-machine.js";
import { emitEvent } from "../events/emitter.js";

export class TransactionEngine {
  constructor(bus) {
    this.bus = bus;
  }

  process(event) {
    const next = nextState(event.event);
    if (!next) return;

    const newEvent = emitEvent(next, event.payload);
    this.bus.publish(newEvent);
  }
}
TE1

# === ROUTING ENGINE ===
cat << 'RE1' > src/orchestrator/routing-engine.js
export class RoutingEngine {
  route(payload) {
    return {
      provider: "FakeProvider",
      bankRail: "FakeBankRail"
    };
  }
}
RE1

# === CORE ORCHESTRATOR ===
cat << 'ORCH' > src/orchestrator/core-orchestrator.js
import { EventBus } from "../queue/event-bus.js";
import { TransactionEngine } from "./transaction-engine.js";
import { RoutingEngine } from "./routing-engine.js";

export class CoreOrchestrator {
  constructor() {
    this.bus = new EventBus();
    this.tx = new TransactionEngine(this.bus);
    this.routing = new RoutingEngine();
  }

  start(event) {
    this.bus.publish(event);
    this.bus.consume((e) => this.tx.process(e));
  }
}
ORCH

# === CLI: ORCHESTRATOR GENERATOR ===
cat << 'CLI' > src/cli/cyborg.js
#!/usr/bin/env node
import fs from "fs";
import { generateProvider } from "../generators/provider-generator.js";
import { generateBankRail } from "../generators/bank-rail-generator.js";

const cmd = process.argv[2];
const name = process.argv[3];

if (cmd === "provider") {
  const code = generateProvider(name);
  fs.writeFileSync(\`src/adapters/providers/\${name}-provider.js\`, code);
  console.log("✅ Provider oluşturuldu:", name);
}

if (cmd === "bankrail") {
  const code = generateBankRail(name);
  fs.writeFileSync(\`src/adapters/bank-rails/\${name}-bankrail.js\`, code);
  console.log("✅ Bank rail oluşturuldu:", name);
}

if (cmd === "orchestrator") {
  fs.copyFileSync("src/orchestrator/core-orchestrator.js", \`src/orchestrator/\${name}-orchestrator.js\`);
  console.log("✅ Orchestrator oluşturuldu:", name);
}
CLI

chmod +x src/cli/cyborg.js

echo "✅ CYBORG-OS v4 tamamlandı!"
