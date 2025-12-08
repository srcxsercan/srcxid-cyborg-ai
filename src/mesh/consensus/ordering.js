export function orderEvents(events) {
  return events.sort((a, b) => a.timestamp - b.timestamp);
}
