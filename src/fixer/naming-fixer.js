export function suggestNamingFix(filename) {
  const kebab = filename
    .replace(/([a-z])([A-Z])/g, "$1-$2")
    .toLowerCase();

  return {
    original: filename,
    suggested: kebab
  };
}
