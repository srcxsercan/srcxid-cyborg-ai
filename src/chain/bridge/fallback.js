export function bridgeFallback(chain, policy) {
  if (chain === "solana") return "ethereum";
  return policy.rules.fallback_chain;
}
