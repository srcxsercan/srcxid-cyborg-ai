const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: role OK');
}).listen(PORT, () => {
  console.log('✅ role running on port ' + PORT);
});
