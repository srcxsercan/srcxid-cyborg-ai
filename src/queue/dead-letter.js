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
