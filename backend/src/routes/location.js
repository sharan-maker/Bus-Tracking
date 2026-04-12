const express = require('express');
const locationController = require('../controllers/locationController');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// Driver updates location (protected)
router.post('/update', authMiddleware, locationController.updateLocation);

// Student gets bus location (public)
router.get('/bus/:bus_id', locationController.getBusLocation);
router.get('/all', locationController.getAllLocations);

module.exports = router;