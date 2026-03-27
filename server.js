const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// ── Metrics (Prometheus) ─────────────────────────────────────
// Simple manual counters — no extra library needed
let requestCount = 0;
let errorCount = 0;
const startTime = Date.now();

// Middleware — runs on every request, increments counter
app.use((req, res, next) => {
  requestCount++;
  res.on('finish', () => {
    if (res.statusCode >= 400) errorCount++;
  });
  next();
});

// ── Routes ───────────────────────────────────────────────────
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

// Prometheus scrapes this endpoint every 15 seconds
app.get('/metrics', (req, res) => {
  const uptimeSeconds = Math.floor((Date.now() - startTime) / 1000);
  const memoryMB = (process.memoryUsage().heapUsed / 1024 / 1024).toFixed(2);

  // Prometheus expects this exact plain-text format
  const metrics = [
    '# HELP http_requests_total Total number of HTTP requests',
    '# TYPE http_requests_total counter',
    `http_requests_total ${requestCount}`,
    '',
    '# HELP http_errors_total Total number of HTTP errors',
    '# TYPE http_errors_total counter',
    `http_errors_total ${errorCount}`,
    '',
    '# HELP app_uptime_seconds Application uptime in seconds',
    '# TYPE app_uptime_seconds gauge',
    `app_uptime_seconds ${uptimeSeconds}`,
    '',
    '# HELP app_memory_mb Memory usage in MB',
    '# TYPE app_memory_mb gauge',
    `app_memory_mb ${memoryMB}`,
  ].join('\n');

  res.set('Content-Type', 'text/plain');
  res.send(metrics);
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;