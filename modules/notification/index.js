const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: notification OK');
}).listen(PORT, () => {
  console.log('✅ notification running on port ' + PORT);
});
