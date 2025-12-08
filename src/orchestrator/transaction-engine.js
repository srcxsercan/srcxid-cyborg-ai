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
