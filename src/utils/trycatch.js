export async function safe(fn) {
  try {
    return await fn();
  } catch (err) {
    return { error: true, message: err.message };
  }
}
