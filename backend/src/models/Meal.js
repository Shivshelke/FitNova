/**
 * Meal Model
 * Records a user's meal entry with food items and nutritional data
 */

const mongoose = require('mongoose');

// Sub-schema for each food item in a meal
const mealItemSchema = new mongoose.Schema({
  foodName: { type: String, required: true },
  quantity: { type: Number, default: 1 },      // serving quantity
  unit: { type: String, default: 'serving' },   // g, ml, piece, serving
  calories: { type: Number, default: 0 },
  protein: { type: Number, default: 0 },        // in grams
  carbs: { type: Number, default: 0 },          // in grams
  fat: { type: Number, default: 0 },            // in grams
  fiber: { type: Number, default: 0 },          // in grams
});

const mealSchema = new mongoose.Schema(
  {
    // Which user logged this meal
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    // Date of the meal (YYYY-MM-DD stored as Date)
    date: {
      type: Date,
      default: Date.now,
    },

    // Meal type
    mealType: {
      type: String,
      enum: ['breakfast', 'lunch', 'dinner', 'snack'],
      required: true,
    },

    // List of food items in this meal
    items: [mealItemSchema],

    // ── Calculated Totals (auto-computed) ──────────────────
    totalCalories: { type: Number, default: 0 },
    totalProtein: { type: Number, default: 0 },
    totalCarbs: { type: Number, default: 0 },
    totalFat: { type: Number, default: 0 },

    notes: { type: String, default: '' },
  },
  { timestamps: true }
);

// ── Auto-calculate totals before saving ──────────────────────────────────────
mealSchema.pre('save', function (next) {
  this.totalCalories = this.items.reduce((sum, item) => sum + (item.calories || 0), 0);
  this.totalProtein = this.items.reduce((sum, item) => sum + (item.protein || 0), 0);
  this.totalCarbs = this.items.reduce((sum, item) => sum + (item.carbs || 0), 0);
  this.totalFat = this.items.reduce((sum, item) => sum + (item.fat || 0), 0);
  next();
});

// Index for fast date+user queries
mealSchema.index({ user: 1, date: -1 });

const Meal = mongoose.model('Meal', mealSchema);
module.exports = Meal;
