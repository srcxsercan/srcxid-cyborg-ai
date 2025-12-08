export class MeshNode {
  constructor(id) {
    this.id = id;
    this.peers = [];
    this.alive = true;
  }

  addPeer(node) {
    this.peers.push(node);
  }

  broadcast(message) {
    for (const peer of this.peers) {
      if (peer.alive) peer.receive(message, this.id);
    }
  }

  receive(message, from) {
    console.log(\`📡 Node \${this.id} received message from \${from}: \`, message);
  }
}
