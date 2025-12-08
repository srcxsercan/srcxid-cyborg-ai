export function detectSmells(code) {
  const smells = [];

  if (code.includes("console.log")) {
    smells.push("Remove console.log from production code");
  }

  if (code.includes("function") && code.length > 500) {
    smells.push("Function too long — consider splitting");
  }

  if (code.includes("var ")) {
    smells.push("Use let/const instead of var");
  }

  if (code.includes("TODO")) {
    smells.push("TODO found — ensure completion");
  }

  return smells;
}
