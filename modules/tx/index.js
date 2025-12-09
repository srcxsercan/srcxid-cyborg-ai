const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: tx OK');
}).listen(PORT, () => {
  console.log('✅ tx running on port ' + PORT);
});
