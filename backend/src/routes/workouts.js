/**
 * Workout Routes
 */
const express = require('express');
const router = express.Router();
const workoutController = require('../controllers/workoutController');
const authMiddleware = require('../middleware/authMiddleware');

// All workout routes require auth
router.use(authMiddleware);

router.get('/', workoutController.getWorkouts);
router.get('/:id', workoutController.getWorkout);
router.post('/', workoutController.createWorkout);
router.put('/:id', workoutController.updateWorkout);
router.delete('/:id', workoutController.deleteWorkout);

module.exports = router;
