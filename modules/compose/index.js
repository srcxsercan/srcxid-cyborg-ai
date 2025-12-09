const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: compose OK');
}).listen(PORT, () => {
  console.log('✅ compose running on port ' + PORT);
});
