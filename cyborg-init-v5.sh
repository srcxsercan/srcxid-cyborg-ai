#!/bin/bash

echo "⚡ CYBORG-OS v5: Autonomous Recovery Engine başlatılıyor..."

mkdir -p src/recovery
mkdir -p src/queue
mkdir -p .greptile

# === GREPTILE RECOVERY RULES ===
cat << 'G1' > .greptile/recovery.md
# CYBORG-OS v5 — Autonomous Recovery Rules

Greptile bu projede:
- Retry mekanizmasının exponential backoff içerdiğini doğrulamalı
- Dead-letter queue'nun doğru çalıştığını kontrol etmeli
- Orchestrator çökse bile event'lerin kaybolmadığını doğrulamalı
- safe() wrapper'ın tüm external call'larda kullanıldığını kontrol etmeli
- Event replay mekanizmasını enforce etmeli
G1

# === RETRY ENGINE ===
cat << 'RETRY' > src/recovery/retry-engine.js
export async function retry(fn, attempts = 5) {
  let delay = 200;
  for (let i = 0; i < attempts; i++) {
    try {
      return await fn();
    } catch (err) {
      if (i === attempts - 1) throw err;
      await new Promise(res => setTimeout(res, delay));
      delay *= 2; // exponential backoff
    }
  }
}
RETRY

# === DEAD LETTER QUEUE ===
cat << 'DLQ' > src/queue/dead-letter.js
export class DeadLetterQueue {
  constructor() {
    this.failed = [];
  }

  push(event, reason) {
    this.failed.push({ event, reason, timestamp: Date.now() });
  }

  list() {
    return this.failed;
  }
}
DLQ

# === EVENT REPLAY ENGINE ===
cat << 'REPLAY' > src/recovery/replay-engine.js
export class ReplayEngine {
  constructor(bus) {
    this.bus = bus;
    this.history = [];
  }

  record(event) {
    this.history.push(event);
  }

  replay() {
    for (const event of this.history) {
      this.bus.publish(event);
    }
  }
}
REPLAY

# === ORCHESTRATOR RECOVERY WRAPPER ===
cat << 'ORC' > src/recovery/orchestrator-recovery.js
import { retry } from "./retry-engine.js";
import { DeadLetterQueue } from "../queue/dead-letter.js";

export class OrchestratorRecovery {
  constructor(bus) {
    this.bus = bus;
    this.dlq = new DeadLetterQueue();
  }

  async safeProcess(handler, event) {
    try {
      await retry(() => handler(event));
    } catch (err) {
      this.dlq.push(event, err.message);
    }
  }
}
ORC

echo "✅ CYBORG-OS v5 tamamlandı!"
