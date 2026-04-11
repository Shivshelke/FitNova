/**
 * AI Controller
 * Rule-based AI suggestions for workouts and diet
 * No external AI API needed — pure logic based on user's goal and progress
 */

const ProgressLog = require('../models/ProgressLog');
const Meal = require('../models/Meal');

/**
 * GET /api/ai/workout-suggestions
 * Returns personalized workout suggestions based on user's goal
 */
exports.getWorkoutSuggestions = async (req, res, next) => {
  try {
    const { goal } = req.user;

    // Rule-based suggestion engine
    const suggestions = {
      weight_loss: [
        { title: 'HIIT Cardio Blast', reason: 'Burns fat fast with high-intensity intervals', duration: 30, intensity: 'High', type: 'cardio' },
        { title: 'Jump Rope Session', reason: 'Excellent calorie burner, 400–600 kcal/hr', duration: 20, intensity: 'Medium', type: 'cardio' },
        { title: 'Full Body Circuit', reason: 'Keeps heart rate elevated, burns more calories', duration: 45, intensity: 'Medium', type: 'home' },
        { title: 'Morning Walk/Jog', reason: 'Low-impact fat burning in fasted state', duration: 45, intensity: 'Low', type: 'outdoor' },
      ],
      weight_gain: [
        { title: 'Heavy Upper Body', reason: 'Compound movements stimulate muscle growth', duration: 60, intensity: 'High', type: 'gym' },
        { title: 'Leg Day (Squats & Deadlifts)', reason: 'Largest muscle groups = maximum anabolic response', duration: 60, intensity: 'High', type: 'gym' },
        { title: 'Progressive Overload Push', reason: 'Add weight each session for hypertrophy', duration: 50, intensity: 'High', type: 'gym' },
        { title: 'Shoulder & Arms Mass Builder', reason: 'Isolation + compounds for upper body mass', duration: 45, intensity: 'Medium', type: 'gym' },
      ],
      muscle_building: [
        { title: 'PPL Push Day', reason: 'Push muscles (chest, shoulders, triceps) focus', duration: 60, intensity: 'High', type: 'gym' },
        { title: 'PPL Pull Day', reason: 'Back and bicep hypertrophy session', duration: 60, intensity: 'High', type: 'gym' },
        { title: 'Leg Hypertrophy', reason: 'Volume training for quad, hamstring, glute growth', duration: 55, intensity: 'High', type: 'gym' },
        { title: 'Calisthenics Strength', reason: 'Build functional strength with bodyweight', duration: 40, intensity: 'Medium', type: 'home' },
      ],
      maintenance: [
        { title: 'Yoga Flow', reason: 'Maintain flexibility and reduce stress', duration: 30, intensity: 'Low', type: 'home' },
        { title: 'Moderate Cardio', reason: 'Keep cardiovascular system healthy', duration: 35, intensity: 'Medium', type: 'outdoor' },
        { title: 'Full Body Strength', reason: 'Maintain muscle mass with moderate loads', duration: 45, intensity: 'Medium', type: 'gym' },
        { title: 'Active Recovery', reason: 'Light movement to stay active on rest days', duration: 20, intensity: 'Low', type: 'home' },
      ],
    };

    const userSuggestions = suggestions[goal] || suggestions['maintenance'];

    res.status(200).json({
      success: true,
      goal,
      suggestions: userSuggestions,
      tip: `Based on your goal of ${goal.replace('_', ' ')}, we recommend focusing on the above workouts for best results!`,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/ai/diet-tips
 * Returns diet suggestions based on today's macro intake vs targets
 */
exports.getDietTips = async (req, res, next) => {
  try {
    const { goal, dailyCalorieTarget, weight } = req.user;

    // Get today's meal data
    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));

    const meals = await Meal.find({ user: req.user._id, date: { $gte: startOfDay, $lte: endOfDay } });

    const totalCalories = meals.reduce((s, m) => s + m.totalCalories, 0);
    const totalProtein = meals.reduce((s, m) => s + m.totalProtein, 0);
    const totalCarbs = meals.reduce((s, m) => s + m.totalCarbs, 0);
    const totalFat = meals.reduce((s, m) => s + m.totalFat, 0);

    // Recommended protein: 1.6–2.2g per kg body weight
    const recommendedProtein = weight ? Math.round(weight * 1.8) : 120;
    const calorieTarget = dailyCalorieTarget || 2000;

    const tips = [];

    // Protein check
    if (totalProtein < recommendedProtein * 0.7) {
      tips.push({ type: 'warning', emoji: '🥩', tip: `You're low on protein! Aim for ${recommendedProtein}g today. Add chicken, eggs, or Greek yogurt.` });
    } else if (totalProtein >= recommendedProtein) {
      tips.push({ type: 'success', emoji: '💪', tip: `Great protein intake! You've hit your protein target of ${recommendedProtein}g.` });
    }

    // Calorie check
    const remaining = calorieTarget - totalCalories;
    if (remaining > 500 && meals.length > 0) {
      tips.push({ type: 'info', emoji: '🍽️', tip: `You still have ${remaining} kcal remaining for today. Don't skip meals!` });
    } else if (totalCalories > calorieTarget * 1.1) {
      tips.push({ type: 'warning', emoji: '⚠️', tip: `You've exceeded your daily calorie target by ${Math.round(totalCalories - calorieTarget)} kcal.` });
    }

    // Hydration reminder
    tips.push({ type: 'info', emoji: '💧', tip: 'Remember to drink at least 2.5L of water throughout the day.' });

    // Goal-specific tips
    const goalTips = {
      weight_loss: { emoji: '🥗', tip: 'Focus on high-fiber, high-protein foods to stay full longer and burn fat.' },
      weight_gain: { emoji: '🍚', tip: 'Eat a calorie surplus with complex carbs (rice, oats) and protein after workouts.' },
      muscle_building: { emoji: '🥚', tip: 'Have a protein-rich meal within 30 mins post-workout for muscle repair.' },
      maintenance: { emoji: '⚖️', tip: 'Keep your macros balanced: 40% carbs, 30% protein, 30% fat is a good ratio.' },
    };

    tips.push({ type: 'goal', ...goalTips[goal || 'maintenance'] });

    res.status(200).json({
      success: true,
      todayStats: { totalCalories, totalProtein, totalCarbs, totalFat, remaining },
      tips,
    });
  } catch (error) {
    next(error);
  }
};
