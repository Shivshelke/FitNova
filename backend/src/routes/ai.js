/**
 * AI Suggestions Routes
 */
const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/workout-suggestions', aiController.getWorkoutSuggestions);
router.get('/diet-tips', aiController.getDietTips);

module.exports = router;
