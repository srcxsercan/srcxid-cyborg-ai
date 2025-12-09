const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: alias OK');
}).listen(PORT, () => {
  console.log('✅ alias running on port ' + PORT);
});
