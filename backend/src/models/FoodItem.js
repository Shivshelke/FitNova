/**
 * FoodItem Model
 * Master list of food items with nutritional data
 * Used for the food search feature
 * Populated via seedData.js
 */

const mongoose = require('mongoose');

const foodItemSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      index: true, // Indexed for fast text search
    },
    brand: {
      type: String,
      default: 'Generic',
    },
    category: {
      type: String,
      enum: ['dairy', 'meat', 'vegetables', 'fruits', 'grains', 'snacks', 'beverages', 'supplements', 'other'],
      default: 'other',
    },

    // ── Nutrition per 100g/100ml ──────────────────────────
    servingSize: { type: Number, default: 100 },
    servingUnit: { type: String, default: 'g' },
    calories: { type: Number, required: true },     // kcal per serving
    protein: { type: Number, default: 0 },          // grams
    carbs: { type: Number, default: 0 },            // grams
    fat: { type: Number, default: 0 },              // grams
    fiber: { type: Number, default: 0 },            // grams
    sugar: { type: Number, default: 0 },            // grams
    sodium: { type: Number, default: 0 },           // mg

    // Is this item in the seeded dataset or user-added?
    isCustom: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

// Text index for full-text search across name and brand
foodItemSchema.index({ name: 'text', brand: 'text' });

const FoodItem = mongoose.model('FoodItem', foodItemSchema);
module.exports = FoodItem;
