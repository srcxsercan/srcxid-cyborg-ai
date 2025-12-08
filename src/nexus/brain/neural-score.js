export function neuralScore(context) {
  let score = 0;

  // Routing score
  score += context.routing?.score || 0;

  // Compliance score
  if (context.compliance?.status === "CLEAR") score += 50;
  if (context.compliance?.status === "FLAGGED") score -= 100;

  // Ledger validity
  if (context.ledger?.entries?.length === 2) score += 30;
  else score -= 50;

  // Payload risk
  if (context.payload.amount > 10000) score -= 20;

  return score;
}
