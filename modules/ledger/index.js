const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: ledger OK');
}).listen(PORT, () => {
  console.log('✅ ledger running on port ' + PORT);
});
