const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: config OK');
}).listen(PORT, () => {
  console.log('✅ config running on port ' + PORT);
});
