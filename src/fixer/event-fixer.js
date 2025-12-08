export function fixEventPipeline(events) {
  const required = [
    "payment_requested",
    "payment_validated",
    "payment_routed",
    "payment_executed",
    "payment_settled"
  ];

  const missing = required.filter(e => !events.includes(e));

  return {
    missing,
    patch: missing.map(e => \`emitEvent("\${e}", payload);\`)
  };
}
