export async function failover(routingBrain, payload) {
  const primary = await routingBrain.choose(payload);

  if (!primary) return null;

  if (primary.score < 50) {
    console.log("⚠️ Primary provider weak, searching failover...");
    const backup = await routingBrain.choose({ ...payload, risk: 10 });
    return backup || primary;
  }

  return primary;
}
