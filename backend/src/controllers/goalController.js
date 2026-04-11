/**
 * Goal Controller
 * Manages user fitness goals and calculates completion percentage
 */

const Goal = require('../models/Goal');
const ProgressLog = require('../models/ProgressLog');

/**
 * GET /api/goals
 * Get user's active goals
 */
exports.getGoals = async (req, res, next) => {
  try {
    const goals = await Goal.find({ user: req.user._id }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, goals });
  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/goals
 * Create a new goal
 */
exports.createGoal = async (req, res, next) => {
  try {
    // Deactivate previous active goals of same type
    await Goal.updateMany({ user: req.user._id, goalType: req.body.goalType, isActive: true }, { isActive: false });

    const goal = await Goal.create({ ...req.body, user: req.user._id });
    res.status(201).json({ success: true, goal });
  } catch (error) {
    next(error);
  }
};

/**
 * PUT /api/goals/:id
 * Update a goal (also recalculates completion %)
 */
exports.updateGoal = async (req, res, next) => {
  try {
    const goal = await Goal.findOneAndUpdate(
      { _id: req.params.id, user: req.user._id },
      req.body,
      { new: true, runValidators: true }
    );
    if (!goal) return res.status(404).json({ success: false, message: 'Goal not found.' });
    res.status(200).json({ success: true, goal });
  } catch (error) {
    next(error);
  }
};

/**
 * DELETE /api/goals/:id
 * Delete a goal
 */
exports.deleteGoal = async (req, res, next) => {
  try {
    const goal = await Goal.findOneAndDelete({ _id: req.params.id, user: req.user._id });
    if (!goal) return res.status(404).json({ success: false, message: 'Goal not found.' });
    res.status(200).json({ success: true, message: 'Goal deleted.' });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/goals/completion
 * Calculate goal completion percentage based on recent progress logs
 */
exports.getGoalCompletion = async (req, res, next) => {
  try {
    const goals = await Goal.find({ user: req.user._id, isActive: true });

    // Get today's progress log
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayLog = await ProgressLog.findOne({ user: req.user._id, date: today });

    const completionData = goals.map((goal) => {
      let percentage = 0;

      // Weight goal completion
      if (goal.targetWeight && goal.currentWeight && todayLog?.weight) {
        const totalChange = Math.abs(goal.targetWeight - goal.currentWeight);
        const achieved = Math.abs(todayLog.weight - goal.currentWeight);
        percentage = Math.min(100, Math.round((achieved / (totalChange || 1)) * 100));
      }

      // Steps goal completion (today)
      if (goal.targetSteps && todayLog?.steps) {
        percentage = Math.min(100, Math.round((todayLog.steps / goal.targetSteps) * 100));
      }

      return {
        _id: goal._id,
        goalType: goal.goalType,
        completionPercentage: percentage,
        targetWeight: goal.targetWeight,
        targetSteps: goal.targetSteps,
        deadline: goal.deadline,
      };
    });

    res.status(200).json({ success: true, completionData });
  } catch (error) {
    next(error);
  }
};
