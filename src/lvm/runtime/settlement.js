export function settle(policy, payload) {
  return {
    settled_at: Date.now(),
    status: "settled"
  };
}
