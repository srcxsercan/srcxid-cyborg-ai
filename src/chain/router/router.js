import { chainHealth } from "../health/health.js";

export async function chooseChain(payload, registry, policy) {
  if (payload.countryRisk > 70) return policy.rules.high_risk_country;

  const preferred = policy.rules.low_fee_preferred;
  const health = await chainHealth(preferred);

  if (health.gas < 20) return preferred;

  return policy.rules.fallback_chain;
}
