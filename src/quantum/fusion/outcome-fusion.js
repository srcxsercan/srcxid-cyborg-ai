export function fuseQuantumOutcomes(states) {
  const sorted = states.sort((a, b) => b.finalScore - a.finalScore);
  return sorted[0];
}
