const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: makefile OK');
}).listen(PORT, () => {
  console.log('✅ makefile running on port ' + PORT);
});
