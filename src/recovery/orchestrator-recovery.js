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
