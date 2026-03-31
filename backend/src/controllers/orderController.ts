import { Response, NextFunction } from 'express';
import Razorpay from 'razorpay';
import crypto from 'crypto';
import { Order } from '../models/Order';
import { Menu } from '../models/Menu';
import { IAuthRequest, IApiResponse } from '../types';
import { config } from '../config/config';

// Initialize Razorpay
const razorpay = new Razorpay({
  key_id: config.RAZORPAY_KEY_ID,
  key_secret: config.RAZORPAY_KEY_SECRET
});

export const createOrder = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const { messId, items, totalPrice, paymentMethod } = req.body;

    // Validate item availability against the menu
    const menu = await Menu.findOne({ messId });
    if (menu) {
      for (const orderedItem of items) {
        const menuItem = menu.items.find(
          (mi: any) => mi.name === orderedItem.name
        );
        if (menuItem) {
          if (!menuItem.isAvailable) {
            return res.status(400).json({
              success: false,
              message: `"${orderedItem.name}" is currently not available.`
            });
          }
          if ((menuItem.platesAvailable ?? 0) <= 0) {
            return res.status(400).json({
              success: false,
              message: `"${orderedItem.name}" is sold out.`
            });
          }
          // Deduct plates
          menuItem.platesAvailable = (menuItem.platesAvailable ?? 0) - orderedItem.quantity;
          if ((menuItem.platesAvailable ?? 0) < 0) menuItem.platesAvailable = 0;
        }
      }
      await menu.save();
    }

    const orderData: any = {
      userId: req.user?._id,
      messId,
      items,
      totalPrice,
      paymentMethod,
      status: 'Pending',
      paymentStatus: 'Pending'
    };

    // If payment method is not Wallet, create a Razorpay order
    let razorpayOrderId = null;
    if (paymentMethod === 'UPI' || paymentMethod === 'Card') {
      try {
        const options = {
          amount: Math.round(totalPrice * 100), // paise
          currency: 'INR',
          receipt: `receipt_order_${Date.now()}`
        };
        
        const rzpOrder = await razorpay.orders.create(options);
        razorpayOrderId = rzpOrder.id;
        orderData.razorpayOrderId = rzpOrder.id;
      } catch (rzpError: any) {
        console.error('Razorpay Order Creation Failed:', rzpError);
        return res.status(400).json({ // Return 400 to avoid "Unauthorized access" banner
          success: false,
          message: 'Failed to initiate payment gateway. Please check your payment keys.',
          error: rzpError.error?.description || rzpError.message
        });
      }
    } else if (paymentMethod === 'Wallet') {
        // Handle wallet deduction here if needed
        orderData.status = 'Confirmed';
        orderData.paymentStatus = 'Completed';
    }

    const order = new Order(orderData);
    await order.save();

    const response: IApiResponse = {
      success: true,
      message: 'Order initiated successfully',
      data: order
    };

    return res.status(201).json(response);
  } catch (error) {
    return next(error);
  }
};

export const verifyRazorpayPayment = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const { razorpayOrderId, razorpayPaymentId, razorpaySignature } = req.body;

    if (!config.RAZORPAY_KEY_SECRET) {
      return res.status(500).json({
        success: false,
        message: 'Razorpay secret key is not configured on server'
      });
    }

    const signature = razorpayOrderId + '|' + razorpayPaymentId;
    const expectedSignature = crypto
      .createHmac('sha256', config.RAZORPAY_KEY_SECRET)
      .update(signature.toString())
      .digest('hex');

    if (expectedSignature === razorpaySignature) {
      const order = await Order.findOneAndUpdate(
        { razorpayOrderId: razorpayOrderId },
        { 
          paymentStatus: 'Completed', 
          razorpayPaymentId: razorpayPaymentId,
          razorpaySignature: razorpaySignature,
          status: 'Confirmed'
        },
        { new: true }
      );

      if (!order) {
        return res.status(404).json({
          success: false,
          message: 'Order not found'
        });
      }

      const response: IApiResponse = {
        success: true,
        message: 'Payment verified successfully. Order confirmed.',
        data: order
      };

      return res.status(200).json(response);
    } else {
      // Payment verification failed
      await Order.findOneAndUpdate(
        { razorpayOrderId: razorpayOrderId },
        { paymentStatus: 'Failed' }
      );

      return res.status(400).json({
        success: false,
        message: 'Invalid signature. Payment verification failed.'
      });
    }
  } catch (error) {
    return next(error);
  }
};

export const getMyOrders = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const orders = await Order.find({ userId: req.user?._id }).sort({ createdAt: -1 });

    const response: IApiResponse = {
      success: true,
      message: 'Your orders fetched successfully',
      data: orders
    };

    return res.status(200).json(response);
  } catch (error) {
    return next(error);
  }
};

export const getOrderById = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const order = await Order.findById(id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    const response: IApiResponse = {
      success: true,
      message: 'Order fetched successfully',
      data: order
    };

    return res.status(200).json(response);
  } catch (error) {
    return next(error);
  }
};

export const getMessOrders = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const { messId } = req.params;
    const orders = await Order.find({ messId }).sort({ createdAt: -1 });

    const response: IApiResponse = {
      success: true,
      message: 'Mess orders fetched successfully',
      data: orders
    };

    return res.status(200).json(response);
  } catch (error) {
    return next(error);
  }
};

export const getMessDashboardStats = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const { messId } = req.params;
    
    // Stats calculation
    const allOrders = await Order.find({ messId });
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayOrders = allOrders.filter(o => new Date(o.orderDate) >= today);

    const totalOrders = allOrders.length;
    const totalRevenue = allOrders
        .filter(o => o.status !== 'Cancelled')
        .reduce((sum, o) => sum + o.totalPrice, 0);

    const meals = {
      Breakfast: { orders: 0, pending: 0 },
      Lunch: { orders: 0, pending: 0 },
      Dinner: { orders: 0, pending: 0 },
      Extra: { orders: 0, pending: 0 }
    };

    todayOrders.forEach(o => {
      // Find the first item's mealType (proxy for whole order)
      const mealType = o.items[0]?.mealType as keyof typeof meals;
      if (mealType && meals[mealType]) {
        meals[mealType].orders++;
        if (o.status !== 'Delivered' && o.status !== 'Cancelled') {
          meals[mealType].pending++;
        }
      }
    });

    const response: IApiResponse = {
      success: true,
      message: 'Dashboard stats fetched successfully',
      data: {
        totalOrders,
        totalRevenue,
        mealsLeft: allOrders.filter(o => o.status !== 'Delivered' && o.status !== 'Cancelled').length,
        todayStats: meals
      }
    };

    return res.status(200).json(response);
  } catch (error) {
    return next(error);
  }
};

export const updateOrderStatus = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const { orderId, status } = req.body;
    const order = await Order.findById(orderId);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    // Add authorization check later
    order.status = status;
    await order.save();

    const response: IApiResponse = {
      success: true,
      message: 'Order status updated successfully',
      data: order
    };

    return res.status(200).json(response);
  } catch (error) {
    return next(error);
  }
};
