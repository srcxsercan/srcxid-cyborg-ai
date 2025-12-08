export function anomalyScore(policy, history, payload) {
  const avg = history.reduce((a, t) => a + t.amount, 0) / (history.length || 1);
  const spike = payload.amount / (avg || 1);

  if (spike >= policy.rules.anomaly.sudden_spike_threshold) {
    return "Anomaly detected: sudden spike in transaction amount";
  }

  return null;
}
