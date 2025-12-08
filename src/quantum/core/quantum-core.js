import { generateQuantumStates } from "../state/state-generator.js";
import { evaluateState } from "../probability/probability-engine.js";
import { fuseQuantumOutcomes } from "../fusion/outcome-fusion.js";

export class QuantumExecutionLayer {
  constructor(nexus) {
    this.nexus = nexus;
  }

  async execute(payload) {
    const base = await this.nexus.execute(payload);

    const states = generateQuantumStates(payload);

    const evaluated = states.map(s => ({
      ...s,
      finalScore: evaluateState(s, base.context)
    }));

    const best = fuseQuantumOutcomes(evaluated);

    return {
      quantum_states: evaluated,
      best_outcome: best,
      decision: best.path.includes("APPROVE")
        ? "APPROVE"
        : best.path.includes("REVIEW")
        ? "REVIEW"
        : "DECLINE"
    };
  }
}
