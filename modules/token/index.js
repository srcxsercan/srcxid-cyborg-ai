const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: token OK');
}).listen(PORT, () => {
  console.log('✅ token running on port ' + PORT);
});
