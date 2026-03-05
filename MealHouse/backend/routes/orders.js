const express = require('express');
const router = express.Router();
const Order = require('../models/Order');

// GET /api/orders - Get all orders (with filters)
router.get('/', async (req, res) => {
  try {
    const { user, mess, status, page = 1, limit = 10 } = req.query;
    
    // Build query
    let query = {};
    
    if (user) {
      query.user = user;
    }
    
    if (mess) {
      query.mess = mess;
    }
    
    if (status) {
      query.status = status;
    }
    
    // Execute query with pagination
    const orders = await Order.find(query)
      .populate('user', 'name email phone')
      .populate('mess', 'name cuisine image')
      .populate('items.mealGroup', 'name price')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ orderDate: -1 });
    
    const total = await Order.countDocuments(query);
    
    res.json({
      success: true,
      message: 'Orders retrieved successfully',
      data: orders,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch orders',
      error: error.message
    });
  }
});

// GET /api/orders/:id - Get order by ID
router.get('/:id', async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('user', 'name email phone')
      .populate('mess', 'name cuisine image address contactPhone')
      .populate('items.mealGroup', 'name price image description');
    
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Order retrieved successfully',
      data: order
    });
  } catch (error) {
    console.error('Error fetching order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch order',
      error: error.message
    });
  }
});

// POST /api/orders - Create new order
router.post('/', async (req, res) => {
  try {
    const orderData = req.body;
    
    // Create new order
    const order = new Order(orderData);
    await order.save();
    
    // Populate details
    await order.populate([
      { path: 'user', select: 'name email phone' },
      { path: 'mess', select: 'name cuisine image' },
      { path: 'items.mealGroup', select: 'name price' }
    ]);
    
    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: order
    });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create order',
      error: error.message
    });
  }
});

// PUT /api/orders/:id - Update order status
router.put('/:id', async (req, res) => {
  try {
    const order = await Order.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate([
      { path: 'user', select: 'name email phone' },
      { path: 'mess', select: 'name cuisine image' },
      { path: 'items.mealGroup', select: 'name price' }
    ]);
    
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Order updated successfully',
      data: order
    });
  } catch (error) {
    console.error('Error updating order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update order',
      error: error.message
    });
  }
});

// PUT /api/orders/:id/rate - Rate and review order
router.put('/:id/rate', async (req, res) => {
  try {
    const { rating, review } = req.body;
    
    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { rating, review },
      { new: true, runValidators: true }
    );
    
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Order rated successfully',
      data: order
    });
  } catch (error) {
    console.error('Error rating order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to rate order',
      error: error.message
    });
  }
});

// DELETE /api/orders/:id - Cancel order
router.delete('/:id', async (req, res) => {
  try {
    const { cancellationReason } = req.body;
    
    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { 
        status: 'cancelled',
        cancellationReason,
        deliveryDate: new Date()
      },
      { new: true }
    );
    
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Order cancelled successfully',
      data: order
    });
  } catch (error) {
    console.error('Error cancelling order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to cancel order',
      error: error.message
    });
  }
});

module.exports = router;
