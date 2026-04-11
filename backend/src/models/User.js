/**
 * User Model
 * Stores user account info, profile details, and fitness settings
 */

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    // ── Account Info ──────────────────────────────────────
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
    },
    password: {
      type: String,
      minlength: 6,
      select: false, // Don't return password in queries by default
    },
    googleId: {
      type: String,
      default: null,
    },
    avatar: {
      type: String,
      default: null,
    },

    // ── Physical Profile ──────────────────────────────────
    age: {
      type: Number,
      min: 10,
      max: 120,
    },
    weight: {
      type: Number, // in kg
      min: 20,
    },
    height: {
      type: Number, // in cm
      min: 50,
    },
    gender: {
      type: String,
      enum: ['male', 'female', 'other'],
      default: 'other',
    },

    // ── Fitness Goal ──────────────────────────────────────
    goal: {
      type: String,
      enum: ['weight_loss', 'weight_gain', 'maintenance', 'muscle_building'],
      default: 'maintenance',
    },

    // ── Daily Targets ─────────────────────────────────────
    dailyCalorieTarget: {
      type: Number,
      default: 2000,
    },
    dailyStepsTarget: {
      type: Number,
      default: 10000,
    },
    dailyWaterTarget: {
      type: Number, // in ml
      default: 2500,
    },

    // ── Settings ──────────────────────────────────────────
    darkMode: {
      type: Boolean,
      default: true,
    },
    notificationsEnabled: {
      type: Boolean,
      default: true,
    },

    // ── Profile completion flag ────────────────────────────
    profileComplete: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true, // Adds createdAt and updatedAt automatically
  }
);

// ── Hash password before saving ───────────────────────────────────────────────
userSchema.pre('save', async function (next) {
  // Only hash if password field was modified
  if (!this.isModified('password')) return next();
  // Salt rounds: 12 is strong but not too slow
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// ── Method to compare entered password with hashed password ──────────────────
userSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

const User = mongoose.model('User', userSchema);
module.exports = User;
