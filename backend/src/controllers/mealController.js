/**
 * Meal Controller
 * Handles meal logging, retrieval, and deletion for diet tracking
 */

const Meal = require('../models/Meal');

/**
 * POST /api/meals
 * Log a meal (breakfast/lunch/dinner/snack)
 */
exports.addMeal = async (req, res, next) => {
  try {
    const meal = await Meal.create({
      ...req.body,
      user: req.user._id,
    });
    res.status(201).json({ success: true, meal });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/meals
 * Get meals for a specific date (defaults to today)
 * Query: ?date=YYYY-MM-DD&mealType=breakfast
 */
exports.getMeals = async (req, res, next) => {
  try {
    const { date, mealType } = req.query;
    const targetDate = date ? new Date(date) : new Date();

    // Build date range for the full day
    const startOfDay = new Date(targetDate.setHours(0, 0, 0, 0));
    const endOfDay = new Date(targetDate.setHours(23, 59, 59, 999));

    const filter = {
      user: req.user._id,
      date: { $gte: startOfDay, $lte: endOfDay },
    };

    if (mealType) filter.mealType = mealType;

    const meals = await Meal.find(filter).sort({ createdAt: 1 });

    // Calculate daily totals
    const dailyTotals = meals.reduce(
      (acc, meal) => {
        acc.calories += meal.totalCalories;
        acc.protein += meal.totalProtein;
        acc.carbs += meal.totalCarbs;
        acc.fat += meal.totalFat;
        return acc;
      },
      { calories: 0, protein: 0, carbs: 0, fat: 0 }
    );

    res.status(200).json({ success: true, meals, dailyTotals });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/meals/:id
 * Get a single meal by ID
 */
exports.getMeal = async (req, res, next) => {
  try {
    const meal = await Meal.findOne({ _id: req.params.id, user: req.user._id });
    if (!meal) return res.status(404).json({ success: false, message: 'Meal not found.' });
    res.status(200).json({ success: true, meal });
  } catch (error) {
    next(error);
  }
};

/**
 * PUT /api/meals/:id
 * Update a meal entry
 */
exports.updateMeal = async (req, res, next) => {
  try {
    const meal = await Meal.findOne({ _id: req.params.id, user: req.user._id });
    if (!meal) return res.status(404).json({ success: false, message: 'Meal not found.' });
    Object.assign(meal, req.body);
    await meal.save(); // triggers pre-save totals calculation
    res.status(200).json({ success: true, meal });
  } catch (error) {
    next(error);
  }
};

/**
 * DELETE /api/meals/:id
 * Delete a meal entry
 */
exports.deleteMeal = async (req, res, next) => {
  try {
    const meal = await Meal.findOneAndDelete({ _id: req.params.id, user: req.user._id });
    if (!meal) return res.status(404).json({ success: false, message: 'Meal not found.' });
    res.status(200).json({ success: true, message: 'Meal deleted.' });
  } catch (error) {
    next(error);
  }
};
