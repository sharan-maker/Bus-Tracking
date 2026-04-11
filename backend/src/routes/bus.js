const express = require('express');
const busController = require('../controllers/busController');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// Protected routes (need login token)
router.post('/add', authMiddleware, busController.addBus);
router.post('/route/add', authMiddleware, busController.addRoute);

// Public routes
router.get('/all', busController.getAllBuses);
router.get('/search', busController.searchBuses);

module.exports = router;
