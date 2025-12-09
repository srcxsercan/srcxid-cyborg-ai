const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: health OK');
}).listen(PORT, () => {
  console.log('✅ health running on port ' + PORT);
});
