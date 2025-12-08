export function velocityCheck(policy, history, payload) {
  const lastMinute = history.filter(t => Date.now() - t.timestamp < 60000);
  const lastHour = history.filter(t => Date.now() - t.timestamp < 3600000);

  if (lastMinute.reduce((a, t) => a + t.amount, 0) + payload.amount >
      policy.rules.velocity.max_amount_per_minute) {
    return "Velocity breach: amount per minute exceeded";
  }

  if (lastHour.length + 1 > policy.rules.velocity.max_transactions_per_hour) {
    return "Velocity breach: too many transactions per hour";
  }

  return null;
}
