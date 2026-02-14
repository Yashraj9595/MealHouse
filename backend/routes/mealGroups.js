const express = require('express');
const { body } = require('express-validator');
const {
    getMealGroups,
    getMealGroup,
    createMealGroup,
    updateMealGroup,
    deleteMealGroup,
    updateAvailability
} = require('../controllers/mealGroupController');
const { protect, authorize } = require('../middleware/auth');
const validate = require('../middleware/validate');

const router = express.Router({ mergeParams: true });

// Validation rules
const mealGroupValidation = [
    body('name').trim().notEmpty().withMessage('Meal group name is required'),
    body('mealType').isIn(['breakfast', 'lunch', 'dinner', 'snacks']).withMessage('Invalid meal type'),
    body('category').isIn(['veg', 'non-veg']).withMessage('Invalid category'),
    body('items').isArray({ min: 1 }).withMessage('At least one meal item is required'),
    body('items.*.name').trim().notEmpty().withMessage('Item name is required'),
    body('price').isFloat({ min: 0 }).withMessage('Price must be a positive number'),
    body('totalTiffins').isInt({ min: 0 }).withMessage('Total tiffins must be a positive number')
];

// Public routes
router.get('/', getMealGroups);

// Protected routes
router.post('/', protect, authorize('mess_owner', 'admin'), mealGroupValidation, validate, createMealGroup);

// Single meal group routes
router.get('/:id', getMealGroup);
router.put('/:id', protect, authorize('mess_owner', 'admin'), updateMealGroup);
router.delete('/:id', protect, authorize('mess_owner', 'admin'), deleteMealGroup);
router.put('/:id/availability', protect, authorize('mess_owner', 'admin'), updateAvailability);

module.exports = router;
