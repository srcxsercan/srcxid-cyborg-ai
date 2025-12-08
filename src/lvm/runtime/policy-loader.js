import fs from "fs";

export function loadPolicy(name = "default") {
  const raw = fs.readFileSync(\`src/lvm/policies/\${name}.json\`, "utf8");
  return JSON.parse(raw);
}
