const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: subscription OK');
}).listen(PORT, () => {
  console.log('✅ subscription running on port ' + PORT);
});
