/**
 * Progress Log Routes
 */
const express = require('express');
const router = express.Router();
const progressController = require('../controllers/progressController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.post('/', progressController.logProgress);
router.get('/today', progressController.getTodayProgress);
router.get('/weight', progressController.getWeightHistory);
router.get('/', progressController.getProgressRange);

module.exports = router;
