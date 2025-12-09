const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: treasury OK');
}).listen(PORT, () => {
  console.log('✅ treasury running on port ' + PORT);
});
