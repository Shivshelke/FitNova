/**
 * Progress Controller
 * Handles daily progress logging and chart data retrieval
 */

const ProgressLog = require('../models/ProgressLog');

/**
 * POST /api/progress
 * Add or update today's progress log (upsert by date)
 */
exports.logProgress = async (req, res, next) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Upsert: create if not exists, update if exists
    const log = await ProgressLog.findOneAndUpdate(
      { user: req.user._id, date: today },
      { ...req.body, user: req.user._id, date: today },
      { upsert: true, new: true, runValidators: true, setDefaultsOnInsert: true }
    );

    res.status(200).json({ success: true, log });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/progress/today
 * Get today's progress log
 */
exports.getTodayProgress = async (req, res, next) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const log = await ProgressLog.findOne({ user: req.user._id, date: today });
    res.status(200).json({ success: true, log: log || null });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/progress
 * Get progress logs for a date range
 * Query: ?range=week|month|year | ?startDate=&endDate=
 */
exports.getProgressRange = async (req, res, next) => {
  try {
    const { range, startDate, endDate } = req.query;
    const filter = { user: req.user._id };
    const now = new Date();

    if (range) {
      const start = new Date();
      if (range === 'week') start.setDate(now.getDate() - 7);
      else if (range === 'month') start.setMonth(now.getMonth() - 1);
      else if (range === 'year') start.setFullYear(now.getFullYear() - 1);
      filter.date = { $gte: start, $lte: now };
    } else if (startDate || endDate) {
      filter.date = {};
      if (startDate) filter.date.$gte = new Date(startDate);
      if (endDate) filter.date.$lte = new Date(endDate);
    }

    const logs = await ProgressLog.find(filter).sort({ date: 1 });
    res.status(200).json({ success: true, count: logs.length, logs });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/progress/weight
 * Get weight history for graph
 */
exports.getWeightHistory = async (req, res, next) => {
  try {
    const { range = 'month' } = req.query;
    const start = new Date();
    if (range === 'week') start.setDate(start.getDate() - 7);
    else if (range === 'month') start.setMonth(start.getMonth() - 1);
    else if (range === 'year') start.setFullYear(start.getFullYear() - 1);

    const logs = await ProgressLog.find({
      user: req.user._id,
      date: { $gte: start },
      weight: { $ne: null },
    })
      .select('date weight')
      .sort({ date: 1 });

    res.status(200).json({ success: true, data: logs });
  } catch (error) {
    next(error);
  }
};
