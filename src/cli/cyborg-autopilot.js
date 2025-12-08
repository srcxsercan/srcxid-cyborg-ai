#!/usr/bin/env node
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const deploymentPath = path.join(__dirname, "../starship/deployment.json");
const autopilotCfgPath = path.join(__dirname, "../starship/autopilot-targets.json");

if (!fs.existsSync(deploymentPath)) {
  console.error("❌ deployment.json not found. Run v15 first (cyborg-init-v15.sh).");
  process.exit(1);
}

const deployment = JSON.parse(fs.readFileSync(deploymentPath, "utf8"));
const autopilotCfg = JSON.parse(fs.readFileSync(autopilotCfgPath, "utf8"));

const env = process.argv[2] || "local";
const target = process.argv[3] || autopilotCfg.default_target;

if (!deployment.environments[env]) {
  console.error("❌ Unknown environment:", env);
  console.log("Available:", Object.keys(deployment.environments).join(", "));
  process.exit(1);
}

if (!autopilotCfg.targets.includes(target)) {
  console.error("❌ Unknown target:", target);
  console.log("Available targets:", autopilotCfg.targets.join(", "));
  process.exit(1);
}

const cfg = deployment.environments[env];

function ensureOutputDir() {
  const outDir = path.join(process.cwd(), "autopilot", "output");
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
  return outDir;
}

function generateDockerCompose(envName, cfg) {
  const outDir = ensureOutputDir();
  const filePath = path.join(outDir, \`docker-compose.\${envName}.yml\`);

  if (envName === "local") {
    const content = [
      "version: '3.9'",
      "services:",
      "  nexus:",
      "    image: node:22",
      "    working_dir: /app",
      "    volumes:",
      "      - ./:/app",
      "    command: " + JSON.stringify(cfg.orchestrator || "node src/cli/cyborg-nexus.js"),
      "  mesh:",
      "    image: node:22",
      "    working_dir: /app",
      "    volumes:",
      "      - ./:/app",
      "    command: " + JSON.stringify(cfg.mesh || "node src/cli/cyborg-mesh.js")
    ].join("\\n");

    fs.writeFileSync(filePath, content, "utf8");
    return filePath;
  }

  const lines = ["version: '3.9'", "services:"];
  for (const [name, svc] of Object.entries(cfg.services || {})) {
    lines.push(
      \`  \${name}:\`,
      \`    image: \${svc.image}\`,
      \`    deploy:\`,
      \`      replicas: \${svc.replicas || 1}\`
    );
  }

  fs.writeFileSync(filePath, lines.join("\\n"), "utf8");
  return filePath;
}

function generateK8s(envName, cfg) {
  const outDir = ensureOutputDir();
  const filePath = path.join(outDir, \`k8s-\${envName}.yaml\`);

  const lines = [];

  for (const [name, svc] of Object.entries(cfg.services || {})) {
    lines.push(
      "---",
      "apiVersion: apps/v1",
      "kind: Deployment",
      \`metadata:\`,
      \`  name: \${name}-deployment\`,
      "spec:",
      \`  replicas: \${svc.replicas || 1}\`,
      "  selector:",
      "    matchLabels:",
      \`      app: \${name}\`,
      "  template:",
      "    metadata:",
      "      labels:",
      \`        app: \${name}\`,
      "    spec:",
      "      containers:",
      "        - name: " + name,
      \`          image: \${svc.image}\`,
      "          ports:",
      "            - containerPort: 3000"
    );
  }

  fs.writeFileSync(filePath, lines.join("\\n"), "utf8");
  return filePath;
}

let generatedPath;

if (target === "docker-compose") {
  generatedPath = generateDockerCompose(env, cfg);
} else if (target === "k8s") {
  generatedPath = generateK8s(env, cfg);
}

console.log("🤖 Starship Autopilot");
console.log("Environment:", env);
console.log("Target:", target);
console.log("Generated:", generatedPath);
