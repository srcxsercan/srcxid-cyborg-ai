const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: dispute OK');
}).listen(PORT, () => {
  console.log('✅ dispute running on port ' + PORT);
});
