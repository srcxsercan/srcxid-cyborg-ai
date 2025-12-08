export class DistributedBus {
  constructor(nodes) {
    this.nodes = nodes;
    this.events = [];
  }

  publish(event) {
    this.events.push(event);
    for (const node of this.nodes) {
      if (node.alive) node.receive(event, "BUS");
    }
  }

  getOrderedEvents() {
    return this.events.sort((a, b) => a.timestamp - b.timestamp);
  }
}
