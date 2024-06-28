// Import the express module
const express = require('express');

// Create an Express application
const app = express();

// Define a port to listen to
const PORT = process.env.PORT || 3000;

// Define a route handler for the default home page
app.get('/', (req, res) => {
  res.send('Hello, world!');
});

// Start the server and listen on the defined port
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
