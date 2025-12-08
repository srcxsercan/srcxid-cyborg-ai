#!/bin/bash

echo "🛰️ CYBORG-OS v15: Starship Deployment Matrix oluşturuluyor..."

mkdir -p src/starship
mkdir -p src/cli

# === STARSHIP DEPLOYMENT MATRIX ===
cat << 'MNF' > src/starship/deployment.json
{
  "environments": {
    "local": {
      "description": "Developer laptop / macOS",
      "orchestrator": "node src/cli/cyborg-nexus.js",
      "mesh": "node src/cli/cyborg-mesh.js",
      "lvm": "node src/cli/cyborg-lvm.js",
      "compliance": "node src/cli/cyborg-compliance.js",
      "multichain": "node src/cli/cyborg-chain.js",
      "quantum": "node src/cli/cyborg-quantum.js",
      "about": "node src/cli/cyborg-about.js"
    },
    "dev": {
      "description": "Shared DEV environment",
      "cluster": "k8s-dev-cluster-01",
      "region": "eu-central-1",
      "services": {
        "orchestrator": {
          "image": "srcx/orchestrator:dev",
          "replicas": 2
        },
        "mesh": {
          "image": "srcx/mesh:dev",
          "replicas": 3
        },
        "lvm": {
          "image": "srcx/lvm:dev",
          "replicas": 2
        },
        "compliance": {
          "image": "srcx/compliance:dev",
          "replicas": 2
        }
      }
    },
    "prod": {
      "description": "Production Starship",
      "cluster": "k8s-prod-cluster-01",
      "region": "eu-west-1",
      "services": {
        "orchestrator": {
          "image": "srcx/orchestrator:prod",
          "replicas": 4
        },
        "mesh": {
          "image": "srcx/mesh:prod",
          "replicas": 5
        },
        "lvm": {
          "image": "srcx/lvm:prod",
          "replicas": 4
        },
        "compliance": {
          "image": "srcx/compliance:prod",
          "replicas": 3
        },
        "multichain": {
          "image": "srcx/multichain:prod",
          "replicas": 3
        },
        "quantum": {
          "image": "srcx/quantum:prod",
          "replicas": 2
        }
      }
    }
  }
}
MNF

# === CYBORG DEPLOY PLAN CLI ===
cat << 'CLI' > src/cli/cyborg-deploy-plan.js
#!/usr/bin/env node
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const deploymentPath = path.join(__dirname, "../starship/deployment.json");
const deployment = JSON.parse(fs.readFileSync(deploymentPath, "utf8"));

const env = process.argv[2] || "local";

if (!deployment.environments[env]) {
  console.error("❌ Unknown environment:", env);
  console.log("Available:", Object.keys(deployment.environments).join(", "));
  process.exit(1);
}

const cfg = deployment.environments[env];

console.log("🛰️ Starship Deployment Matrix");
console.log("Environment:", env);
console.log("Description:", cfg.description || "(no description)");

if (env === "local") {
  console.log("\\nCommands:");
  for (const [name, cmd] of Object.entries(cfg)) {
    if (name === "description") continue;
    console.log("-", name, "=>", cmd);
  }
} else {
  console.log("\\nCluster:", cfg.cluster);
  console.log("Region:", cfg.region);
  console.log("\\nServices:");
  for (const [name, svc] of Object.entries(cfg.services || {})) {
    console.log("-", name, "=> image:", svc.image, "| replicas:", svc.replicas);
  }
}
CLI

chmod +x src/cli/cyborg-deploy-plan.js

echo "✅ CYBORG-OS v15 (Starship Deployment Matrix + cyborg-deploy-plan) tamamlandı!"
