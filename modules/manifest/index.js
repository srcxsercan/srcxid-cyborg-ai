const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: manifest OK');
}).listen(PORT, () => {
  console.log('✅ manifest running on port ' + PORT);
});
