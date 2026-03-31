import { Router } from 'express';
import { createOrder, getMyOrders, getOrderById, getMessOrders, updateOrderStatus, getMessDashboardStats, verifyRazorpayPayment } from '../controllers/orderController';
import { authenticate } from '../middleware/auth';

const router = Router();

// Protected routes
router.post('/', authenticate, createOrder);
router.post('/razorpay/verify', authenticate, verifyRazorpayPayment);
router.get('/my/orders', authenticate, getMyOrders);
router.get('/:id', authenticate, getOrderById);
router.get('/mess/:messId', authenticate, getMessOrders);
router.get('/mess/:messId/stats', authenticate, getMessDashboardStats);
router.patch('/status', authenticate, updateOrderStatus);

export default router;
