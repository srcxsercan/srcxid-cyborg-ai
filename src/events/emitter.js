export function emitEvent(name, data) {
  return {
    event: name,
    timestamp: Date.now(),
    correlation_id: data?.correlation_id || crypto.randomUUID(),
    payload: data
  }
}
