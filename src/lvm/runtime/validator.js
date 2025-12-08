export function validate(policy, payload) {
  for (const rule of policy.rules.validate) {
    const expr = rule
      .replace("amount", payload.amount)
      .replace("currency", \`"\${payload.currency}"\`)
      .replace("source_account", \`"\${payload.source_account}"\`)
      .replace("destination_account", \`"\${payload.destination_account}"\`);

    if (!eval(expr)) {
      throw new Error(\`Validation failed: \${rule}\`);
    }
  }
}
