/**
 * WorkoutLog Controller
 * Handles logging workout sessions and retrieving history
 */

const WorkoutLog = require('../models/WorkoutLog');

/**
 * POST /api/workout-logs
 * Log a completed workout session
 */
exports.logWorkout = async (req, res, next) => {
  try {
    const log = await WorkoutLog.create({
      ...req.body,
      user: req.user._id,
    });
    res.status(201).json({ success: true, log });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/workout-logs
 * Get user's workout history with optional date filtering
 * Query params: ?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD&limit=10
 */
exports.getWorkoutLogs = async (req, res, next) => {
  try {
    const { startDate, endDate, limit = 20 } = req.query;
    const filter = { user: req.user._id };

    if (startDate || endDate) {
      filter.date = {};
      if (startDate) filter.date.$gte = new Date(startDate);
      if (endDate) filter.date.$lte = new Date(new Date(endDate).setHours(23, 59, 59));
    }

    const logs = await WorkoutLog.find(filter)
      .sort({ date: -1 })
      .limit(parseInt(limit))
      .populate('workout', 'name type');

    res.status(200).json({ success: true, count: logs.length, logs });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/workout-logs/:id
 * Get a single workout log entry
 */
exports.getWorkoutLog = async (req, res, next) => {
  try {
    const log = await WorkoutLog.findOne({ _id: req.params.id, user: req.user._id })
      .populate('workout', 'name type');
    if (!log) return res.status(404).json({ success: false, message: 'Log not found.' });
    res.status(200).json({ success: true, log });
  } catch (error) {
    next(error);
  }
};

/**
 * DELETE /api/workout-logs/:id
 * Delete a workout log entry
 */
exports.deleteWorkoutLog = async (req, res, next) => {
  try {
    const log = await WorkoutLog.findOneAndDelete({ _id: req.params.id, user: req.user._id });
    if (!log) return res.status(404).json({ success: false, message: 'Log not found.' });
    res.status(200).json({ success: true, message: 'Log deleted.' });
  } catch (error) {
    next(error);
  }
};
