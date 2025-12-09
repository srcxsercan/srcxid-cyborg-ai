const http = require('http');
const PORT = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.end('SRCX Module: starship OK');
}).listen(PORT, () => {
  console.log('✅ starship running on port ' + PORT);
});
