import mongoose, { Document, Schema } from 'mongoose';
import { IOrder } from '../types';

export interface IOrderDocument extends Omit<IOrder, '_id'>, Document {
  toJSON(): Partial<IOrder>;
}

const orderSchema = new Schema<IOrderDocument>({
  userId: {
    type: Schema.Types.ObjectId as any,
    ref: 'User',
    required: [true, 'User ID is required']
  },
  messId: {
    type: Schema.Types.ObjectId as any,
    ref: 'Mess',
    required: [true, 'Mess ID is required']
  },
  items: [{
    name: {
      type: String,
      required: true
    },
    quantity: {
      type: Number,
      required: true,
      min: 1
    },
    price: {
      type: Number,
      required: true
    },
    mealType: {
      type: String,
      enum: ['Breakfast', 'Lunch', 'Dinner', 'Extra'],
      required: false
    }
  }],
  totalPrice: {
    type: Number,
    required: true,
    min: 0
  },
  status: {
    type: String,
    enum: ['Pending', 'Confirmed', 'Preparing', 'Ready', 'OutForDelivery', 'Delivered', 'Cancelled'],
    default: 'Pending'
  },
  paymentStatus: {
    type: String,
    enum: ['Pending', 'Completed', 'Failed'],
    default: 'Pending'
  },
  paymentMethod: {
    type: String,
    required: true
  },
  orderDate: {
    type: Date,
    default: Date.now
  },
  razorpayOrderId: {
    type: String,
    required: false
  },
  razorpayPaymentId: {
    type: String,
    required: false
  },
  razorpaySignature: {
    type: String,
    required: false
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes
orderSchema.index({ userId: 1 });
orderSchema.index({ messId: 1 });
orderSchema.index({ status: 1 });
orderSchema.index({ orderDate: -1 });

// Transform output
orderSchema.methods.toJSON = function(): Partial<IOrder> {
  const orderObject = this.toObject();
  delete orderObject.__v;
  return orderObject;
};

export const Order = mongoose.model<IOrderDocument>('Order', orderSchema);
