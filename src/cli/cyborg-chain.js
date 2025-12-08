#!/usr/bin/env node
import registry from "../chain/registry/registry.json" assert { type: "json" };
import { MultiChainSettlement } from "../chain/core/multichain-core.js";

const engine = new MultiChainSettlement(registry);

const result = await engine.settle({
  amount: 1200,
  currency: "USD",
  countryRisk: 20,
  source: "wallet_1",
  destination: "wallet_2"
});

console.log("✅ Multi-Chain Settlement Test:");
console.log(JSON.stringify(result, null, 2));
