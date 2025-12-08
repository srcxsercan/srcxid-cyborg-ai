import routingMap from "./data/routing-map.json" assert { type: "json" };
import { scoreProvider } from "./scoring.js";
import { healthCheck } from "./health-check.js";

export class RoutingBrain {
  constructor(providers) {
    this.providers = providers;
  }

  async choose(payload) {
    const mccList = routingMap.mcc[payload.mcc] || [];
    const countryList = routingMap.country[payload.country] || [];

    const candidates = [...new Set([...mccList, ...countryList])];

    const scored = [];

    for (const name of candidates) {
      const provider = this.providers[name];
      if (!provider) continue;

      const health = await healthCheck(provider);

      const score = scoreProvider({
        latency: health.latency || 9999,
        risk: provider.risk || 50,
        availability: health.status === "UP"
      });

      scored.push({ name, score });
    }

    scored.sort((a, b) => b.score - a.score);

    return scored[0] || null;
  }
}
