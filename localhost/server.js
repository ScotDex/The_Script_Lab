const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello, World!');
});
app.get('/callback', (req, res) => {
  res.send('This is the callback route!');
});
app.listen(8080, () => {
  console.log('Server is running on http://localhost:8080');
});
