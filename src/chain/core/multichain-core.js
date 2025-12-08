import { loadPolicy } from "./policy-loader.js";
import { chooseChain } from "../router/router.js";
import { buildTx } from "../builder/tx-builder.js";
import { executeSettlement } from "../executor/executor.js";
import { bridgeFallback } from "../bridge/fallback.js";

export class MultiChainSettlement {
  constructor(registry, policyName = "default") {
    this.registry = registry;
    this.policy = loadPolicy(policyName);
  }

  async settle(payload) {
    let chain = await chooseChain(payload, this.registry, this.policy);
    let tx = buildTx(chain, payload);

    let result = await executeSettlement(tx);

    if (result.status !== "submitted") {
      chain = bridgeFallback(chain, this.policy);
      tx = buildTx(chain, payload);
      result = await executeSettlement(tx);
    }

    return result;
  }
}
