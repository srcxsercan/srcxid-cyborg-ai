export function buildTx(chain, payload) {
  return {
    chain,
    from: payload.source,
    to: payload.destination,
    amount: payload.amount,
    nonce: Date.now()
  };
}
