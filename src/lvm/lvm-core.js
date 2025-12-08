import { loadPolicy } from "./runtime/policy-loader.js";
import { validate } from "./runtime/validator.js";
import { post } from "./runtime/posting.js";
import { settle } from "./runtime/settlement.js";

export class LedgerVM {
  constructor(policyName = "default") {
    this.policy = loadPolicy(policyName);
  }

  execute(payload) {
    validate(this.policy, payload);
    const entries = post(this.policy, payload);
    const settlement = settle(this.policy, payload);

    return {
      entries,
      settlement
    };
  }
}
