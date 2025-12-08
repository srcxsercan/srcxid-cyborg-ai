export async function chainHealth(chain) {
  return {
    latency: Math.random() * 200,
    gas: Math.random() * 50,
    blockTime: Math.random() * 2,
    status: "UP"
  };
}
