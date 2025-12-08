import fs from "fs";

export function loadCompliancePolicy(name = "default") {
  const raw = fs.readFileSync(\`src/compliance/policies/\${name}.json\`, "utf8");
  return JSON.parse(raw);
}
