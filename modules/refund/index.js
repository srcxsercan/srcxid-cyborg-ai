const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: refund OK');
}).listen(PORT, () => {
  console.log('✅ refund running on port ' + PORT);
});
