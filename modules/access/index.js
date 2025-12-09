const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: access OK');
}).listen(PORT, () => {
  console.log('✅ access running on port ' + PORT);
});
