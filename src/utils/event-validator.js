export function validateEventPipeline(events) {
  const required = [
    "payment_requested",
    "payment_validated",
    "payment_routed",
    "payment_executed",
    "payment_settled"
  ];
  return required.every(e => events.includes(e));
}
