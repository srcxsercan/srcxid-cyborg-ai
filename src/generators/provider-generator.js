export function generateProvider(name) {
  return `
export class ${name}Provider {
  async authorize(payload) {}
  async capture(payload) {}
  async sale(payload) {}
  async refund(payload) {}
  async payout(payload) {}
}
`;
}
