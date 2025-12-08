import fs from "fs";

export function loadPolicy(name = "default") {
  const raw = fs.readFileSync(\`src/chain/policies/\${name}.json\`, "utf8");
  return JSON.parse(raw);
}
