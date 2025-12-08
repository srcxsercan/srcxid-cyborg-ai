export function generateQuantumStates(payload) {
  return [
    { path: "A_APPROVE", weight: 0.32 },
    { path: "A_DECLINE", weight: 0.12 },
    { path: "B_APPROVE", weight: 0.28 },
    { path: "B_REVIEW",  weight: 0.10 },
    { path: "C_APPROVE", weight: 0.15 },
    { path: "C_DECLINE", weight: 0.03 }
  ];
}
