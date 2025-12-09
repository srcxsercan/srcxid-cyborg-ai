const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: shortcut OK');
}).listen(PORT, () => {
  console.log('✅ shortcut running on port ' + PORT);
});
