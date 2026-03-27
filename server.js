const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({ 
    message: 'Hello from DevOps Pipeline!',
    status: 'healthy',
    version: '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Only start server if this file is run directly (not during tests)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;