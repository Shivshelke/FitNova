/**
 * Workout Controller
 * Handles predefined workouts, custom workout creation, and retrieval
 */

const Workout = require('../models/Workout');

/**
 * GET /api/workouts
 * Get all predefined workouts + user's custom workouts
 */
exports.getWorkouts = async (req, res, next) => {
  try {
    const { type, difficulty, goal } = req.query;

    // Build filter - always include predefined + user's own
    const filter = {
      $or: [
        { isPredefined: true },
        { createdBy: req.user._id },
      ],
    };

    if (type) filter.type = type;
    if (difficulty) filter.difficulty = difficulty;
    if (goal) filter.$and = [filter.$and || [], { $or: [{ targetGoal: goal }, { targetGoal: 'all' }] }];

    const workouts = await Workout.find(filter).sort({ isPredefined: -1, name: 1 });

    res.status(200).json({ success: true, count: workouts.length, workouts });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/workouts/:id
 * Get a single workout by ID
 */
exports.getWorkout = async (req, res, next) => {
  try {
    const workout = await Workout.findById(req.params.id);
    if (!workout) {
      return res.status(404).json({ success: false, message: 'Workout not found.' });
    }
    res.status(200).json({ success: true, workout });
  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/workouts
 * Create a custom workout
 */
exports.createWorkout = async (req, res, next) => {
  try {
    const workout = await Workout.create({
      ...req.body,
      isPredefined: false,
      createdBy: req.user._id,
    });
    res.status(201).json({ success: true, workout });
  } catch (error) {
    next(error);
  }
};

/**
 * PUT /api/workouts/:id
 * Update a custom workout (only owner can update)
 */
exports.updateWorkout = async (req, res, next) => {
  try {
    const workout = await Workout.findOne({ _id: req.params.id, createdBy: req.user._id });
    if (!workout) {
      return res.status(404).json({ success: false, message: 'Workout not found or unauthorized.' });
    }
    Object.assign(workout, req.body);
    await workout.save();
    res.status(200).json({ success: true, workout });
  } catch (error) {
    next(error);
  }
};

/**
 * DELETE /api/workouts/:id
 * Delete a custom workout (only owner)
 */
exports.deleteWorkout = async (req, res, next) => {
  try {
    const workout = await Workout.findOneAndDelete({ _id: req.params.id, createdBy: req.user._id });
    if (!workout) {
      return res.status(404).json({ success: false, message: 'Workout not found or unauthorized.' });
    }
    res.status(200).json({ success: true, message: 'Workout deleted.' });
  } catch (error) {
    next(error);
  }
};
