/**
 * Meal Routes
 */
const express = require('express');
const router = express.Router();
const mealController = require('../controllers/mealController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.post('/', mealController.addMeal);
router.get('/', mealController.getMeals);
router.get('/:id', mealController.getMeal);
router.put('/:id', mealController.updateMeal);
router.delete('/:id', mealController.deleteMeal);

module.exports = router;
