export function generateBankRail(name) {
  return `
export class ${name}BankRail {
  async openAccount(payload) {}
  async sendPayment(payload) {}
  async receiveNotification(payload) {}
  async getStatement(payload) {}
}
`;
}
