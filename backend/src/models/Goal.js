/**
 * Goal Model
 * Stores user's fitness goals and tracks completion percentage
 */

const mongoose = require('mongoose');

const goalSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    // ── Goal Targets ──────────────────────────────────────
    targetWeight: { type: Number, default: null },       // kg
    currentWeight: { type: Number, default: null },      // kg (at time of goal creation)
    targetCalories: { type: Number, default: null },     // daily calorie goal
    targetSteps: { type: Number, default: 10000 },       // daily steps goal
    targetWater: { type: Number, default: 2500 },        // ml per day
    targetWorkoutsPerWeek: { type: Number, default: 3 },

    // ── Goal Type ─────────────────────────────────────────
    goalType: {
      type: String,
      enum: ['weight_loss', 'weight_gain', 'maintenance', 'muscle_building'],
      required: true,
    },

    // ── Timeline ──────────────────────────────────────────
    startDate: {
      type: Date,
      default: Date.now,
    },
    deadline: {
      type: Date,
      default: null,
    },

    // ── Status ────────────────────────────────────────────
    isActive: {
      type: Boolean,
      default: true,
    },
    isCompleted: {
      type: Boolean,
      default: false,
    },

    // ── Completion percentage (0-100) ─────────────────────
    completionPercentage: {
      type: Number,
      default: 0,
      min: 0,
      max: 100,
    },

    notes: { type: String, default: '' },
  },
  { timestamps: true }
);

// Index for fast user query
goalSchema.index({ user: 1, isActive: -1 });

const Goal = mongoose.model('Goal', goalSchema);
module.exports = Goal;
