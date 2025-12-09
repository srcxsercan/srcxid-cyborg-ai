const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: status OK');
}).listen(PORT, () => {
  console.log('✅ status running on port ' + PORT);
});
