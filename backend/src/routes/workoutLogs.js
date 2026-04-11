/**
 * Workout Log Routes
 */
const express = require('express');
const router = express.Router();
const workoutLogController = require('../controllers/workoutLogController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.post('/', workoutLogController.logWorkout);
router.get('/', workoutLogController.getWorkoutLogs);
router.get('/:id', workoutLogController.getWorkoutLog);
router.delete('/:id', workoutLogController.deleteWorkoutLog);

module.exports = router;
