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
