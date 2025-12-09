const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: kyc OK');
}).listen(PORT, () => {
  console.log('✅ kyc running on port ' + PORT);
});
