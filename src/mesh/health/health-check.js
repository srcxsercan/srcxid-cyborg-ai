export function checkNodeHealth(node) {
  return {
    id: node.id,
    alive: node.alive,
    timestamp: Date.now()
  };
}
