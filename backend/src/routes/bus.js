const express = require('express');
const busController = require('../controllers/busController');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// Admin routes (protected)
router.post('/add', authMiddleware, busController.addBus);
router.post('/route/add', authMiddleware, busController.addRoute);
router.post('/unavailable', authMiddleware, busController.markBusUnavailable);
router.post('/alternate', authMiddleware, busController.setAlternateRoute);
router.post('/assign', authMiddleware, busController.assignStudentToBus);

// Student routes
router.get('/all', busController.getAllBuses);
router.get('/search', busController.searchBuses);
router.get('/alternate/:route_id', busController.getAlternateRoute);

module.exports = router;