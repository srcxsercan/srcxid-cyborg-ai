const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: balance OK');
}).listen(PORT, () => {
  console.log('✅ balance running on port ' + PORT);
});
