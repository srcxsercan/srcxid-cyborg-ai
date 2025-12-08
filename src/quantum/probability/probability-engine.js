export function evaluateState(state, context) {
  return (
    state.weight *
    (context.routing?.score || 0) +
    (context.compliance?.score || 0) +
    (context.ledger?.score || 0) +
    (context.risk?.score || 0) +
    (context.chain?.score || 0)
  );
}
