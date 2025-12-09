const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: gateway OK');
}).listen(PORT, () => {
  console.log('✅ gateway running on port ' + PORT);
});
