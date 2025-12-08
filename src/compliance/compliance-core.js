import { loadCompliancePolicy } from "./runtime/policy-loader.js";
import { velocityCheck } from "./runtime/velocity.js";
import { anomalyScore } from "./runtime/anomaly.js";
import { patternMatch } from "./runtime/patterns.js";

export class ComplianceEngine {
  constructor(history = [], policyName = "default") {
    this.history = history;
    this.policy = loadCompliancePolicy(policyName);
  }

  evaluate(payload) {
    const checks = [
      velocityCheck(this.policy, this.history, payload),
      anomalyScore(this.policy, this.history, payload),
      patternMatch(this.policy, payload)
    ];

    const issues = checks.filter(Boolean);

    if (issues.length > 0) {
      return {
        status: "FLAGGED",
        issues
      };
    }

    return {
      status: "CLEAR"
    };
  }
}
