const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: profile OK');
}).listen(PORT, () => {
  console.log('✅ profile running on port ' + PORT);
});
