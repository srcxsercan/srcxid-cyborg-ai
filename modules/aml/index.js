const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: aml OK');
}).listen(PORT, () => {
  console.log('✅ aml running on port ' + PORT);
});
