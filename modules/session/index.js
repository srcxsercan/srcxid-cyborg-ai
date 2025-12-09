const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: session OK');
}).listen(PORT, () => {
  console.log('✅ session running on port ' + PORT);
});
