/**
 * Food Controller
 * Handles searching food items from the database
 */

const FoodItem = require('../models/FoodItem');

/**
 * GET /api/food/search
 * Search food items by name
 * Query: ?q=chicken&limit=20
 */
exports.searchFood = async (req, res, next) => {
  try {
    const { q, limit = 20, category } = req.query;

    if (!q || q.trim().length < 1) {
      return res.status(400).json({ success: false, message: 'Search query is required.' });
    }

    const filter = {
      name: { $regex: q, $options: 'i' }, // Case-insensitive partial match
    };

    if (category) filter.category = category;

    const foods = await FoodItem.find(filter).limit(parseInt(limit)).sort({ name: 1 });

    res.status(200).json({ success: true, count: foods.length, foods });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/food/:id
 * Get a single food item by ID
 */
exports.getFoodItem = async (req, res, next) => {
  try {
    const food = await FoodItem.findById(req.params.id);
    if (!food) return res.status(404).json({ success: false, message: 'Food item not found.' });
    res.status(200).json({ success: true, food });
  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/food
 * Add a custom food item (user-created)
 */
exports.addFoodItem = async (req, res, next) => {
  try {
    const food = await FoodItem.create({ ...req.body, isCustom: true });
    res.status(201).json({ success: true, food });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/food/categories
 * List all food categories
 */
exports.getCategories = async (req, res, next) => {
  try {
    const categories = FoodItem.schema.path('category').enumValues;
    res.status(200).json({ success: true, categories });
  } catch (error) {
    next(error);
  }
};
