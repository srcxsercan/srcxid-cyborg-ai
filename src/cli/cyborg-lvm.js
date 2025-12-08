#!/usr/bin/env node
import { LedgerVM } from "../lvm/lvm-core.js";

const vm = new LedgerVM();
const result = vm.execute({
  amount: 100,
  currency: "USD",
  source_account: "wallet_1",
  destination_account: "wallet_2"
});

console.log("✅ LVM Test Result:");
console.log(JSON.stringify(result, null, 2));
