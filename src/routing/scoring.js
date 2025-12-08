export function scoreProvider({ latency, risk, availability }) {
  let score = 100;

  if (latency > 500) score -= 20;
  if (latency > 1000) score -= 40;

  if (risk > 70) score -= 30;
  if (risk > 90) score -= 50;

  if (!availability) score -= 100;

  return score;
}
