import mongoose, { Document, Schema } from 'mongoose';
import { IMenu } from '../types';

export interface IMenuDocument extends Omit<IMenu, '_id'>, Document {
  toJSON(): Partial<IMenu>;
}

const menuSchema = new Schema<IMenuDocument>({
  messId: {
    type: Schema.Types.ObjectId as any,
    ref: 'Mess',
    required: [true, 'Mess ID is required'],
    unique: true
  },
  items: [{
    name: {
      type: String,
      required: true,
      trim: true
    },
    description: {
      type: String,
      trim: true
    },
    price: {
      type: Number,
      required: true,
      min: 0
    },
    category: {
      type: String,
      enum: ['Veg', 'Non-Veg', 'Both', 'Snacks', 'Drinks'],
      default: 'Veg'
    },
    mealType: [{
      type: String,
      enum: ['Breakfast', 'Lunch', 'Dinner', 'Extra'],
      default: ['Extra']
    }],
    isAvailable: {
      type: Boolean,
      default: true
    },
    image: {
      type: String
    },
    ingredients: [{
      type: String
    }],
    platesAvailable: {
      type: Number,
      default: 0
    }
  }]
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes
menuSchema.index({ messId: 1 });

// Transform output
menuSchema.methods.toJSON = function(): Partial<IMenu> {
  const menuObject = this.toObject();
  delete menuObject.__v;
  return menuObject;
};

export const Menu = mongoose.model<IMenuDocument>('Menu', menuSchema);
