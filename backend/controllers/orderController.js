const Order = require('../models/Order');
const MealGroup = require('../models/MealGroup');
const Mess = require('../models/Mess');
const Razorpay = require('razorpay');
const crypto = require('crypto');

// Initialize Razorpay
// Note: We'll initialize inside the function or use a try-catch so it won't crash the whole app if keys are missing initially
const getRazorpayInstance = () => {
    if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
        throw new Error('Razorpay keys not configured in environment variables');
    }
    return new Razorpay({
        key_id: process.env.RAZORPAY_KEY_ID,
        key_secret: process.env.RAZORPAY_KEY_SECRET,
    });
};

// @desc    Create new order
// @route   POST /api/orders
// @access  Private (User)
exports.createOrder = async (req, res, next) => {
    try {
        const { messId, items, deliveryAddress, contactPhone, deliveryTime, specialInstructions } = req.body;

        // Verify mess exists
        const mess = await Mess.findById(messId);
        if (!mess) {
            return res.status(404).json({
                success: false,
                message: 'Mess not found'
            });
        }

        // Validate and process items
        const orderItems = [];
        let totalAmount = 0;

        for (const item of items) {
            const mealGroup = await MealGroup.findById(item.mealGroupId);

            if (!mealGroup) {
                return res.status(404).json({
                    success: false,
                    message: `Meal group ${item.mealGroupId} not found`
                });
            }

            if (!mealGroup.isActive) {
                return res.status(400).json({
                    success: false,
                    message: `${mealGroup.name} is no longer available`
                });
            }

            // Check if enough tiffins available
            if (!mealGroup.hasAvailableTiffins(item.quantity)) {
                return res.status(400).json({
                    success: false,
                    message: `Only ${mealGroup.availableTiffins} tiffins available for ${mealGroup.name}`
                });
            }

            const subtotal = mealGroup.price * item.quantity;
            totalAmount += subtotal;

            orderItems.push({
                mealGroup: mealGroup._id,
                mealGroupName: mealGroup.name,
                items: mealGroup.items,
                quantity: item.quantity,
                price: mealGroup.price,
                subtotal
            });

            // Reduce available tiffins
            await mealGroup.reduceTiffins(item.quantity);
        }

        // Create order
        const order = await Order.create({
            user: req.user.id,
            mess: messId,
            items: orderItems,
            totalAmount,
            deliveryAddress: deliveryAddress || req.user.address,
            contactPhone: contactPhone || req.user.phone,
            deliveryTime,
            specialInstructions
        });

        // Update mess total orders
        await Mess.findByIdAndUpdate(messId, {
            $inc: { totalOrders: 1 }
        });

        // Populate order details
        const populatedOrder = await Order.findById(order._id)
            .populate('user', 'name email phone')
            .populate('mess', 'name address contact');

        res.status(201).json({
            success: true,
            message: 'Order placed successfully',
            data: populatedOrder
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Create Razorpay Order
// @route   POST /api/orders/razorpay/create
// @access  Private (User)
exports.createRazorpayOrder = async (req, res, next) => {
    try {
        const { orderId } = req.body;

        const order = await Order.findById(orderId);

        if (!order) {
            return res.status(404).json({ success: false, message: 'Order not found' });
        }

        // Ensure order belongs to user
        if (order.user.toString() !== req.user.id) {
            return res.status(403).json({ success: false, message: 'Not authorized' });
        }

        const razorpay = getRazorpayInstance();

        const options = {
            amount: Math.round(order.totalAmount * 100), // amount in the smallest currency unit (paise)
            currency: 'INR',
            receipt: order.orderNumber,
        };

        const razorpayOrder = await razorpay.orders.create(options);

        // Save razorpay order id to our DB order
        order.razorpayOrderId = razorpayOrder.id;
        await order.save();

        res.status(200).json({
            success: true,
            data: {
                id: razorpayOrder.id,
                amount: razorpayOrder.amount,
                currency: razorpayOrder.currency,
                receipt: razorpayOrder.receipt,
                keyId: process.env.RAZORPAY_KEY_ID
            }
        });
    } catch (error) {
        console.error('Razorpay Error:', error);
        res.status(500).json({ success: false, message: error.message || 'Payment initiation failed' });
    }
};

// @desc    Verify Razorpay Payment
// @route   POST /api/orders/razorpay/verify
// @access  Private (User)
exports.verifyRazorpayPayment = async (req, res, next) => {
    try {
        const { razorpay_order_id, razorpay_payment_id, razorpay_signature, orderId } = req.body;

        if (!process.env.RAZORPAY_KEY_SECRET) {
            return res.status(500).json({ success: false, message: 'Server payment configuration missing' });
        }

        const body = razorpay_order_id + "|" + razorpay_payment_id;

        const expectedSignature = crypto
            .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
            .update(body.toString())
            .digest("hex");

        const isAuthentic = expectedSignature === razorpay_signature;

        if (isAuthentic) {
            // Update order status
            const order = await Order.findById(orderId);

            if (!order) {
                return res.status(404).json({ success: false, message: 'Order not found' });
            }

            order.paymentStatus = 'paid';
            order.status = 'confirmed'; // Auto-confirm paid orders
            order.paymentMethod = 'online';
            order.razorpayPaymentId = razorpay_payment_id;
            order.razorpaySignature = razorpay_signature;

            await order.save();

            res.status(200).json({
                success: true,
                message: 'Payment verified successfully',
                data: order
            });
        } else {
            res.status(400).json({
                success: false,
                message: 'Invalid payment signature'
            });
        }
    } catch (error) {
        console.error('Razorpay Verify Error:', error);
        res.status(500).json({ success: false, message: 'Payment verification failed' });
    }
};

// @desc    Get all orders (with filters)
// @route   GET /api/orders
// @access  Private
exports.getOrders = async (req, res, next) => {
    try {
        let query = {};

        // If user, show only their orders
        if (req.user.role === 'user') {
            query.user = req.user.id;
        }

        // If mess owner, show only their mess orders
        if (req.user.role === 'mess_owner') {
            const mess = await Mess.findOne({ owner: req.user.id });
            if (mess) {
                query.mess = mess._id;
            }
        }

        // Filter by status
        if (req.query.status) {
            query.status = req.query.status;
        }

        // Filter by date range
        if (req.query.startDate || req.query.endDate) {
            query.createdAt = {};
            if (req.query.startDate) {
                query.createdAt.$gte = new Date(req.query.startDate);
            }
            if (req.query.endDate) {
                query.createdAt.$lte = new Date(req.query.endDate);
            }
        }

        const orders = await Order.find(query)
            .populate('user', 'name email phone')
            .populate('mess', 'name address contact')
            .sort('-createdAt');

        res.status(200).json({
            success: true,
            count: orders.length,
            data: orders
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get single order
// @route   GET /api/orders/:id
// @access  Private
exports.getOrder = async (req, res, next) => {
    try {
        const order = await Order.findById(req.params.id)
            .populate('user', 'name email phone')
            .populate('mess', 'name address contact');

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        // Check authorization
        const mess = await Mess.findById(order.mess._id);
        const isOwner = order.user._id.toString() === req.user.id;
        const isMessOwner = mess && mess.owner.toString() === req.user.id;
        const isAdmin = req.user.role === 'admin';

        if (!isOwner && !isMessOwner && !isAdmin) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to view this order'
            });
        }

        res.status(200).json({
            success: true,
            data: order
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Update order status
// @route   PUT /api/orders/:id/status
// @access  Private (Mess Owner, Admin)
exports.updateOrderStatus = async (req, res, next) => {
    try {
        const { status } = req.body;

        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        // Check authorization
        const mess = await Mess.findById(order.mess);
        if (mess.owner.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to update this order'
            });
        }

        order.status = status;
        await order.save();

        res.status(200).json({
            success: true,
            message: 'Order status updated successfully',
            data: order
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Cancel order
// @route   PUT /api/orders/:id/cancel
// @access  Private (User, Admin)
exports.cancelOrder = async (req, res, next) => {
    try {
        const { reason } = req.body;

        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        // Check authorization
        if (order.user.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to cancel this order'
            });
        }

        // Check if order can be cancelled
        if (['delivered', 'cancelled'].includes(order.status)) {
            return res.status(400).json({
                success: false,
                message: `Cannot cancel order with status: ${order.status}`
            });
        }

        // Restore tiffins
        for (const item of order.items) {
            const mealGroup = await MealGroup.findById(item.mealGroup);
            if (mealGroup) {
                await mealGroup.restoreTiffins(item.quantity);
            }
        }

        order.status = 'cancelled';
        order.cancellationReason = reason;
        order.cancelledAt = new Date();
        order.cancelledBy = req.user.id;
        await order.save();

        res.status(200).json({
            success: true,
            message: 'Order cancelled successfully',
            data: order
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get order statistics (for mess owner)
// @route   GET /api/orders/stats/summary
// @access  Private (Mess Owner, Admin)
exports.getOrderStats = async (req, res, next) => {
    try {
        // Get mess for current user
        const mess = await Mess.findOne({ owner: req.user.id });

        if (!mess && req.user.role !== 'admin') {
            return res.status(404).json({
                success: false,
                message: 'No mess found for this user'
            });
        }

        const matchQuery = req.user.role === 'admin' ? {} : { mess: mess._id };

        const stats = await Order.aggregate([
            { $match: matchQuery },
            {
                $group: {
                    _id: '$status',
                    count: { $sum: 1 },
                    totalRevenue: { $sum: '$totalAmount' }
                }
            }
        ]);

        const totalOrders = await Order.countDocuments(matchQuery);
        const totalRevenue = await Order.aggregate([
            { $match: { ...matchQuery, status: { $ne: 'cancelled' } } },
            { $group: { _id: null, total: { $sum: '$totalAmount' } } }
        ]);

        res.status(200).json({
            success: true,
            data: {
                totalOrders,
                totalRevenue: totalRevenue[0]?.total || 0,
                statusBreakdown: stats
            }
        });
    } catch (error) {
        next(error);
    }
};
