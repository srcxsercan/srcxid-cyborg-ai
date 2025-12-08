export function fuseDecision(context) {
  const score = context.neural_score;

  if (score >= 80) {
    return { decision: "APPROVE", reason: "High neural confidence" };
  }

  if (score >= 40) {
    return { decision: "REVIEW", reason: "Medium confidence, manual check suggested" };
  }

  return { decision: "DECLINE", reason: "Low neural confidence" };
}
