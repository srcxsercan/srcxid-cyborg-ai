const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: payment OK');
}).listen(PORT, () => {
  console.log('✅ payment running on port ' + PORT);
});
