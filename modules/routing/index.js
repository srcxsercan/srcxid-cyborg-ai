const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: routing OK');
}).listen(PORT, () => {
  console.log('✅ routing running on port ' + PORT);
});
