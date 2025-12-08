export function createLedgerEntry({ account, amount, type, correlation_id }) {
  return {
    account,
    amount,
    type,
    correlation_id,
    timestamp: Date.now(),
    immutable: true
  }
}
