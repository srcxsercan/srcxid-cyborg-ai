export function buildContext({ payload, routing, compliance, ledger }) {
  return {
    timestamp: Date.now(),
    payload,
    routing,
    compliance,
    ledger
  };
}
