const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: limits OK');
}).listen(PORT, () => {
  console.log('✅ limits running on port ' + PORT);
});
