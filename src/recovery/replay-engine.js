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
