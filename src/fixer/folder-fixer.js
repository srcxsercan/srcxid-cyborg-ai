export function validateFolder(path) {
  const validRoots = ["core", "domain", "events", "utils", "adapters", "orchestrator"];
  const root = path.split("/")[1];

  if (!validRoots.includes(root)) {
    return {
      valid: false,
      message: "File is in the wrong folder — move to correct module"
    };
  }

  return { valid: true };
}
