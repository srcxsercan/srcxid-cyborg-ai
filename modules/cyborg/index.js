const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: cyborg OK');
}).listen(PORT, () => {
  console.log('✅ cyborg running on port ' + PORT);
});
