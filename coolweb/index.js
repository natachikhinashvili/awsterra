const express = require('express');

const app = express();

app.get('/', (req, res) => {
  res.send('Hello, chavicheri!');
});

app.listen(80, () => {
  console.log('running');
});
