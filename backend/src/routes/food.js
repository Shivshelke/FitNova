/**
 * Food Item Routes
 */
const express = require('express');
const router = express.Router();
const foodController = require('../controllers/foodController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/search', foodController.searchFood);
router.get('/categories', foodController.getCategories);
router.get('/:id', foodController.getFoodItem);
router.post('/', foodController.addFoodItem);

module.exports = router;
