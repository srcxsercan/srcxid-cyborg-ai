export class Gossip {
  constructor(node) {
    this.node = node;
  }

  spread(data) {
    const message = {
      type: "GOSSIP",
      data,
      timestamp: Date.now()
    };
    this.node.broadcast(message);
  }
}
