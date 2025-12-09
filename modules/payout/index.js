const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: payout OK');
}).listen(PORT, () => {
  console.log('✅ payout running on port ' + PORT);
});
