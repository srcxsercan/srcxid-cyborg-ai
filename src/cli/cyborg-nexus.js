#!/usr/bin/env node
import { Nexus } from "../nexus/nexus-core.js";
import { RoutingBrain } from "../routing/routing-brain.js";
import { ComplianceEngine } from "../compliance/compliance-core.js";
import { LedgerVM } from "../lvm/lvm-core.js";

const routingBrain = new RoutingBrain({});
const complianceEngine = new ComplianceEngine([]);
const ledgerVM = new LedgerVM();

const nexus = new Nexus({ routingBrain, complianceEngine, ledgerVM });

const result = await nexus.execute({
  amount: 1200,
  currency: "USD",
  country: "US",
  mcc: "5411",
  source_account: "wallet_1",
  destination_account: "wallet_2"
});

console.log("✅ NEXUS Test Result:");
console.log(JSON.stringify(result, null, 2));
