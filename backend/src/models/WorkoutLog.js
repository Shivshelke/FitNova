/**
 * WorkoutLog Model
 * Records a user's completed workout session
 * Tracks sets, reps, and weight for each exercise
 */

const mongoose = require('mongoose');

// Sub-schema for each logged set
const setSchema = new mongoose.Schema({
  setNumber: { type: Number, required: true },
  reps: { type: Number, default: 0 },
  weight: { type: Number, default: 0 }, // in kg
  duration: { type: Number, default: null }, // in seconds (for cardio)
  completed: { type: Boolean, default: true },
});

// Sub-schema for each exercise performed in a session
const exerciseLogSchema = new mongoose.Schema({
  exerciseName: { type: String, required: true },
  muscleGroup: { type: String, default: 'full_body' },
  sets: [setSchema],
  notes: { type: String, default: '' },
});

const workoutLogSchema = new mongoose.Schema(
  {
    // Which user did this workout
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    // Reference to the workout template (optional - user may do ad-hoc)
    workout: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Workout',
      default: null,
    },

    // Display name of the workout for this session
    workoutName: {
      type: String,
      required: true,
    },

    // All exercises performed with their sets
    exercises: [exerciseLogSchema],

    // Session stats
    totalDuration: { type: Number, default: 0 },  // in minutes
    caloriesBurned: { type: Number, default: 0 },
    notes: { type: String, default: '' },

    // Date this workout was done (defaults to now)
    date: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

// Index for fast user+date queries (history lookup)
workoutLogSchema.index({ user: 1, date: -1 });

const WorkoutLog = mongoose.model('WorkoutLog', workoutLogSchema);
module.exports = WorkoutLog;
