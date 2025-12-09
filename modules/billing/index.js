const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: billing OK');
}).listen(PORT, () => {
  console.log('✅ billing running on port ' + PORT);
});
