const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: webhook OK');
}).listen(PORT, () => {
  console.log('✅ webhook running on port ' + PORT);
});
