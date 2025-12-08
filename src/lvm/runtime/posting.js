export function post(policy, payload) {
  return policy.rules.posting.map(entry => ({
    account: payload[entry.account] || entry.account,
    amount: payload.amount,
    type: entry.type,
    timestamp: Date.now(),
    immutable: true
  }));
}
