/**
 * Workout Model
 * Defines predefined and custom workout templates
 * Each workout contains a list of exercises
 */

const mongoose = require('mongoose');

// Sub-schema for individual exercises in a workout
const exerciseSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, default: '' },
  muscleGroup: {
    type: String,
    enum: ['chest', 'back', 'shoulders', 'arms', 'legs', 'core', 'cardio', 'full_body'],
    default: 'full_body',
  },
  defaultSets: { type: Number, default: 3 },
  defaultReps: { type: Number, default: 10 },
  defaultWeight: { type: Number, default: 0 }, // 0 means bodyweight
  imageUrl: { type: String, default: null },
  duration: { type: Number, default: null }, // in seconds (for cardio)
});

const workoutSchema = new mongoose.Schema(
  {
    // Workout name (e.g., "Upper Body Blast")
    name: {
      type: String,
      required: [true, 'Workout name is required'],
      trim: true,
    },
    description: {
      type: String,
      default: '',
    },

    // Type of workout location
    type: {
      type: String,
      enum: ['gym', 'home', 'outdoor'],
      default: 'gym',
    },

    // Difficulty level
    difficulty: {
      type: String,
      enum: ['beginner', 'intermediate', 'advanced'],
      default: 'beginner',
    },

    // Fitness goal this workout targets
    targetGoal: {
      type: String,
      enum: ['weight_loss', 'weight_gain', 'maintenance', 'muscle_building', 'all'],
      default: 'all',
    },

    // Estimated workout duration in minutes
    estimatedDuration: {
      type: Number,
      default: 45,
    },

    // Calories estimated to burn
    estimatedCalories: {
      type: Number,
      default: 300,
    },

    // List of exercises in this workout
    exercises: [exerciseSchema],

    // Is this a predefined/system workout or user-created?
    isPredefined: {
      type: Boolean,
      default: false,
    },

    // Owner (null for predefined workouts)
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },

    // Category tag
    category: {
      type: String,
      default: 'General',
    },
  },
  { timestamps: true }
);

const Workout = mongoose.model('Workout', workoutSchema);
module.exports = Workout;
