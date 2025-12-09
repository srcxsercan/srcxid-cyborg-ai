const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: admin OK');
}).listen(PORT, () => {
  console.log('✅ admin running on port ' + PORT);
});
