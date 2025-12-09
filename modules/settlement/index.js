const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: settlement OK');
}).listen(PORT, () => {
  console.log('✅ settlement running on port ' + PORT);
});
