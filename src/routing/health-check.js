export async function healthCheck(provider) {
  const start = Date.now();
  try {
    await provider.ping();
    return {
      status: "UP",
      latency: Date.now() - start
    };
  } catch {
    return {
      status: "DOWN",
      latency: null
    };
  }
}
