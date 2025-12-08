export function electLeader(nodes) {
  const aliveNodes = nodes.filter(n => n.alive);
  const leader = aliveNodes.sort((a, b) => b.id - a.id)[0];
  return leader;
}
