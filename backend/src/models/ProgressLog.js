/**
 * ProgressLog Model
 * Daily snapshot of a user's health metrics
 * Used to generate progress charts over time
 */

const mongoose = require('mongoose');

// Sub-schema for body measurements
const measurementsSchema = new mongoose.Schema({
  chest: { type: Number, default: null },   // cm
  waist: { type: Number, default: null },   // cm
  hips: { type: Number, default: null },    // cm
  bicep: { type: Number, default: null },   // cm
  thigh: { type: Number, default: null },   // cm
  calf: { type: Number, default: null },    // cm
});

const progressLogSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    // Date of the log entry (day-level granularity)
    date: {
      type: Date,
      required: true,
    },

    // ── Daily Activity Stats ───────────────────────────────
    steps: { type: Number, default: 0 },
    caloriesBurned: { type: Number, default: 0 },
    caloriesIntake: { type: Number, default: 0 },
    waterIntake: { type: Number, default: 0 },      // in ml
    activeMinutes: { type: Number, default: 0 },

    // ── Body Metrics ──────────────────────────────────────
    weight: { type: Number, default: null },        // kg
    bodyFat: { type: Number, default: null },       // percentage
    bmi: { type: Number, default: null },

    // ── Body Measurements ─────────────────────────────────
    measurements: measurementsSchema,

    // ── Sleep ─────────────────────────────────────────────
    sleepHours: { type: Number, default: null },

    // ── Mood ──────────────────────────────────────────────
    mood: {
      type: String,
      enum: ['great', 'good', 'okay', 'bad', 'terrible'],
      default: null,
    },

    notes: { type: String, default: '' },
  },
  { timestamps: true }
);

// Compound index for efficient date range queries per user
progressLogSchema.index({ user: 1, date: -1 });

// Ensure one log per user per day
progressLogSchema.index({ user: 1, date: 1 }, { unique: true });

const ProgressLog = mongoose.model('ProgressLog', progressLogSchema);
module.exports = ProgressLog;
