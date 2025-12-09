const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: fraud OK');
}).listen(PORT, () => {
  console.log('✅ fraud running on port ' + PORT);
});
