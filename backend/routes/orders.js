const express = require('express');
const { body } = require('express-validator');
const {
    createOrder,
    getOrders,
    getOrder,
    updateOrderStatus,
    cancelOrder,
    getOrderStats,
    createRazorpayOrder,
    verifyRazorpayPayment
} = require('../controllers/orderController');
const { protect, authorize } = require('../middleware/auth');
const validate = require('../middleware/validate');

const router = express.Router();

// Validation rules
const orderValidation = [
    body('messId').notEmpty().withMessage('Mess ID is required'),
    body('items').isArray({ min: 1 }).withMessage('At least one item is required'),
    body('items.*.mealGroupId').notEmpty().withMessage('Meal group ID is required'),
    body('items.*.quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
    body('deliveryTime').notEmpty().withMessage('Delivery time is required'),
    body('contactPhone').matches(/^[0-9]{10}$/).withMessage('Please provide a valid 10-digit phone number')
];

const statusValidation = [
    body('status').isIn(['pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'])
        .withMessage('Invalid status')
];

// All routes are protected
router.use(protect);

// Order routes
router.post('/', orderValidation, validate, createOrder);
router.post('/razorpay/create', createRazorpayOrder);
router.post('/razorpay/verify', verifyRazorpayPayment);
router.get('/', getOrders);
router.get('/my/orders', getOrders);
router.get('/stats/summary', authorize('mess_owner', 'admin'), getOrderStats);
router.get('/:id', getOrder);
router.put('/:id/status', authorize('mess_owner', 'admin'), statusValidation, validate, updateOrderStatus);
router.put('/:id/cancel', cancelOrder);

module.exports = router;
