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
