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
