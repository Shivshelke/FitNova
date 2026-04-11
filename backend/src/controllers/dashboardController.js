/**
 * Dashboard Controller
 * Returns today's aggregated summary for the home screen
 */

const ProgressLog = require('../models/ProgressLog');
const Meal = require('../models/Meal');
const WorkoutLog = require('../models/WorkoutLog');
const Goal = require('../models/Goal');

/**
 * GET /api/dashboard
 * Returns today's health summary: steps, calories in/out, water, workouts
 */
exports.getDashboard = async (req, res, next) => {
  try {
    const user = req.user;
    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));

    // Fetch today's progress log
    const progressLog = await ProgressLog.findOne({ user: user._id, date: startOfDay });

    // Fetch today's meals and sum calories
    const meals = await Meal.find({ user: user._id, date: { $gte: startOfDay, $lte: endOfDay } });
    const totalCaloriesIn = meals.reduce((sum, m) => sum + m.totalCalories, 0);
    const totalProtein = meals.reduce((sum, m) => sum + m.totalProtein, 0);
    const totalCarbs = meals.reduce((sum, m) => sum + m.totalCarbs, 0);
    const totalFat = meals.reduce((sum, m) => sum + m.totalFat, 0);

    // Fetch today's workouts
    const workoutLogs = await WorkoutLog.find({ user: user._id, date: { $gte: startOfDay, $lte: endOfDay } });
    const totalCaloriesBurned = workoutLogs.reduce((sum, w) => sum + (w.caloriesBurned || 0), 0);

    // Get active goals for progress bars
    const goals = await Goal.find({ user: user._id, isActive: true }).limit(3);

    // Daily targets from user profile
    const targets = {
      calories: user.dailyCalorieTarget || 2000,
      steps: user.dailyStepsTarget || 10000,
      water: user.dailyWaterTarget || 2500,
    };

    // Build summary
    const summary = {
      date: new Date().toISOString().split('T')[0],
      user: {
        name: user.name,
        goal: user.goal,
        weight: user.weight,
      },
      steps: {
        current: progressLog?.steps || 0,
        target: targets.steps,
        percentage: Math.min(100, Math.round(((progressLog?.steps || 0) / targets.steps) * 100)),
      },
      calories: {
        intake: totalCaloriesIn,
        burned: progressLog?.caloriesBurned || totalCaloriesBurned,
        target: targets.calories,
        net: totalCaloriesIn - (progressLog?.caloriesBurned || totalCaloriesBurned),
        percentage: Math.min(100, Math.round((totalCaloriesIn / targets.calories) * 100)),
      },
      water: {
        current: progressLog?.waterIntake || 0,
        target: targets.water,
        percentage: Math.min(100, Math.round(((progressLog?.waterIntake || 0) / targets.water) * 100)),
      },
      nutrition: { protein: totalProtein, carbs: totalCarbs, fat: totalFat },
      workoutsToday: workoutLogs.length,
      goals: goals,
    };

    res.status(200).json({ success: true, summary });
  } catch (error) {
    next(error);
  }
};
