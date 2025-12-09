const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: audit OK');
}).listen(PORT, () => {
  console.log('✅ audit running on port ' + PORT);
});
