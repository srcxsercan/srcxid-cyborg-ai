const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: permission OK');
}).listen(PORT, () => {
  console.log('✅ permission running on port ' + PORT);
});
