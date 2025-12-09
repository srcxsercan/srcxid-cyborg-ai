const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: dns OK');
}).listen(PORT, () => {
  console.log('✅ dns running on port ' + PORT);
});
