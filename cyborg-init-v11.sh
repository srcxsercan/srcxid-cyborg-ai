#!/bin/bash

echo "⚡ CYBORG-OS v11: Distributed Cyborg Mesh başlatılıyor..."

mkdir -p src/mesh
mkdir -p src/mesh/nodes
mkdir -p src/mesh/consensus
mkdir -p src/mesh/gossip
mkdir -p src/mesh/health
mkdir -p .greptile

# === GREPTILE MESH RULES ===
cat << 'G1' > .greptile/mesh.md
# CYBORG-OS v11 — Distributed Cyborg Mesh Rules

Greptile bu projede:
- Node'lar arası gossip protocol'ün doğru çalıştığını doğrulamalı
- Leader election mekanizmasını kontrol etmeli
- Consensus ordering'in deterministik olduğunu doğrulamalı
- Node health-check + failover mekanizmasını işaretlemeli
- Distributed event bus'ın event duplication yapmadığını doğrulamalı
G1

# === NODE MODEL ===
cat << 'NODE' > src/mesh/nodes/node.js
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
NODE

# === GOSSIP PROTOCOL ===
cat << 'GOSSIP' > src/mesh/gossip/gossip.js
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
GOSSIP

# === HEALTH CHECK ENGINE ===
cat << 'HEALTH' > src/mesh/health/health-check.js
export function checkNodeHealth(node) {
  return {
    id: node.id,
    alive: node.alive,
    timestamp: Date.now()
  };
}
HEALTH

# === LEADER ELECTION (Bully Algorithm) ===
cat << 'LEADER' > src/mesh/consensus/leader-election.js
export function electLeader(nodes) {
  const aliveNodes = nodes.filter(n => n.alive);
  const leader = aliveNodes.sort((a, b) => b.id - a.id)[0];
  return leader;
}
LEADER

# === CONSENSUS ORDERING ENGINE ===
cat << 'CONS' > src/mesh/consensus/ordering.js
export function orderEvents(events) {
  return events.sort((a, b) => a.timestamp - b.timestamp);
}
CONS

# === DISTRIBUTED EVENT BUS ===
cat << 'DBUS' > src/mesh/distributed-bus.js
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
DBUS

# === CLI: MESH TEST ===
cat << 'CLI' > src/cli/cyborg-mesh.js
#!/usr/bin/env node
import { MeshNode } from "../mesh/nodes/node.js";
import { Gossip } from "../mesh/gossip/gossip.js";
import { electLeader } from "../mesh/consensus/leader-election.js";
import { DistributedBus } from "../mesh/distributed-bus.js";

const n1 = new MeshNode(1);
const n2 = new MeshNode(2);
const n3 = new MeshNode(3);

n1.addPeer(n2);
n1.addPeer(n3);
n2.addPeer(n1);
n2.addPeer(n3);
n3.addPeer(n1);
n3.addPeer(n2);

const gossip = new Gossip(n1);
gossip.spread({ msg: "Mesh network operational" });

const leader = electLeader([n1, n2, n3]);
console.log("👑 Leader elected:", leader.id);

const bus = new DistributedBus([n1, n2, n3]);
bus.publish({ event: "payment_requested", timestamp: Date.now() });

console.log("✅ Ordered events:", bus.getOrderedEvents());
CLI

chmod +x src/cli/cyborg-mesh.js

echo "✅ CYBORG-OS v11 tamamlandı!"
