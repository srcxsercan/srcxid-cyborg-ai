export function patternMatch(policy, payload) {
  for (const rule of policy.rules.patterns) {
    const expr = rule
      .replace("amount", payload.amount)
      .replace("country", \`"\${payload.country}"\`)
      .replace("currency", \`"\${payload.currency}"\`);

    if (eval(expr)) {
      return \`Pattern match triggered: \${rule}\`;
    }
  }
  return null;
}
