import { buildContext } from "./context/context-builder.js";
import { neuralScore } from "./brain/neural-score.js";
import { fuseDecision } from "./brain/decision-fusion.js";

export class Nexus {
  constructor({ routingBrain, complianceEngine, ledgerVM }) {
    this.routingBrain = routingBrain;
    this.complianceEngine = complianceEngine;
    this.ledgerVM = ledgerVM;
  }

  async execute(payload) {
    const routing = await this.routingBrain.choose(payload);
    const compliance = this.complianceEngine.evaluate(payload);
    const ledger = this.ledgerVM.execute(payload);

    const context = buildContext({ payload, routing, compliance, ledger });
    context.neural_score = neuralScore(context);

    const decision = fuseDecision(context);

    return {
      context,
      decision
    };
  }
}
