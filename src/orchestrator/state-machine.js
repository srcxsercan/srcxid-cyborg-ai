export const PipelineStates = {
  REQUESTED: "payment_requested",
  VALIDATED: "payment_validated",
  ROUTED: "payment_routed",
  EXECUTED: "payment_executed",
  SETTLED: "payment_settled"
};

export function nextState(current) {
  const order = Object.values(PipelineStates);
  const index = order.indexOf(current);
  return order[index + 1] || null;
}
