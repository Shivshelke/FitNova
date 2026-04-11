/**
 * FitNova Backend - Main Entry Point
 * Sets up Express server, middleware, and routes
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

// Import DB connection
const connectDB = require('./src/config/db');

// Import all route files
const authRoutes = require('./src/routes/auth');
const workoutRoutes = require('./src/routes/workouts');
const workoutLogRoutes = require('./src/routes/workoutLogs');
const mealRoutes = require('./src/routes/meals');
const foodRoutes = require('./src/routes/food');
const progressRoutes = require('./src/routes/progress');
const goalRoutes = require('./src/routes/goals');
const dashboardRoutes = require('./src/routes/dashboard');
const aiRoutes = require('./src/routes/ai');

// Import centralized error handler
const errorHandler = require('./src/middleware/errorHandler');

// Connect to MongoDB
connectDB();

// Initialize Express app
const app = express();

// ─── MIDDLEWARE ───────────────────────────────────────────────────────────────

// Security headers
app.use(helmet());

// Enable CORS for Flutter app
app.use(cors({
  origin: '*', // In production restrict to your domain
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Parse JSON request bodies
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// HTTP request logger (dev mode)
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// ─── ROUTES ──────────────────────────────────────────────────────────────────

app.use('/api/auth', authRoutes);
app.use('/api/workouts', workoutRoutes);
app.use('/api/workout-logs', workoutLogRoutes);
app.use('/api/meals', mealRoutes);
app.use('/api/food', foodRoutes);
app.use('/api/progress', progressRoutes);
app.use('/api/goals', goalRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/ai', aiRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'FitNova API is running 🚀', timestamp: new Date() });
});

// 404 handler for unknown routes
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// Global error handler (must be last)
app.use(errorHandler);

// ─── START SERVER ─────────────────────────────────────────────────────────────

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`\n🚀 FitNova API running on port ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV}`);
  console.log(`🏥 Health check: http://localhost:${PORT}/health\n`);
});

module.exports = app;
