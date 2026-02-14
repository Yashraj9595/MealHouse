const express = require('express');
const { body } = require('express-validator');
const {
    getMesses,
    getMess,
    createMess,
    updateMess,
    deleteMess,
    getMyMess
} = require('../controllers/messController');
const { protect, authorize } = require('../middleware/auth');
const validate = require('../middleware/validate');

// Import meal group routes
const mealGroupRouter = require('./mealGroups');

const router = express.Router();

// Re-route into meal group router
router.use('/:messId/mealgroups', mealGroupRouter);

// Validation rules
const messValidation = [
    body('name').trim().notEmpty().withMessage('Mess name is required'),
    body('address.street').notEmpty().withMessage('Street address is required'),
    body('address.city').notEmpty().withMessage('City is required'),
    body('address.state').notEmpty().withMessage('State is required'),
    body('address.pincode').matches(/^[0-9]{6}$/).withMessage('Please provide a valid 6-digit pincode'),
    body('contact.phone').matches(/^[0-9]{10}$/).withMessage('Please provide a valid 10-digit phone number'),
    body('mealType').isIn(['veg', 'non-veg', 'both']).withMessage('Invalid meal type')
];

// Public routes
router.get('/', getMesses);
router.get('/:id', getMess);

// Protected routes
router.get('/my/mess', protect, authorize('mess_owner', 'admin'), getMyMess);
router.post('/', protect, authorize('mess_owner', 'admin'), messValidation, validate, createMess);
router.put('/:id', protect, authorize('mess_owner', 'admin'), updateMess);
router.delete('/:id', protect, authorize('mess_owner', 'admin'), deleteMess);

module.exports = router;
