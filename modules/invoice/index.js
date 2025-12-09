const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: invoice OK');
}).listen(PORT, () => {
  console.log('✅ invoice running on port ' + PORT);
});
