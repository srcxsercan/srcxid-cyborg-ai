const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: reporting OK');
}).listen(PORT, () => {
  console.log('✅ reporting running on port ' + PORT);
});
