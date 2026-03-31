import mongoose, { Document, Schema } from 'mongoose';
import { IMess } from '../types';

export interface IMessDocument extends Omit<IMess, '_id'>, Document {
  toJSON(): Partial<IMess>;
}

const messSchema = new Schema<IMessDocument>({
  name: {
    type: String,
    required: [true, 'Mess name is required'],
    trim: true,
    minlength: [2, 'Mess name must be at least 2 characters'],
    maxlength: [100, 'Mess name cannot exceed 100 characters']
  },
  ownerName: {
    type: String,
    required: [true, 'Owner name is required'],
    trim: true
  },
  ownerId: {
    type: Schema.Types.ObjectId as any,
    ref: 'User',
    required: [true, 'Owner ID is required']
  },
  mobile: {
    type: String,
    required: [true, 'Mobile number is required'],
    trim: true
  },
  description: {
    type: String,
    required: [true, 'Description is required'],
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  cuisineType: {
    type: String,
    required: [true, 'Cuisine type is required'],
    default: 'Mixed'
  },
  address: {
    type: String,
    required: [true, 'Address is required']
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
      required: true
    },
    coordinates: {
      type: [Number],
      required: true
    }
  },
  photos: [{
    type: String
  }],
  logo: {
    type: String
  },
  rating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5
  },
  numReviews: {
    type: Number,
    default: 0
  },
  isApproved: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  },
  operatingHours: [{
    day: String,
    isOpen: Boolean,
    breakfast: { start: String, end: String },
    lunch: { start: String, end: String },
    dinner: { start: String, end: String }
  }]
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes
messSchema.index({ location: '2dsphere' });
messSchema.index({ ownerId: 1 });
messSchema.index({ name: 'text' });
messSchema.index({ isActive: 1 });
messSchema.index({ isApproved: 1 });

// Transform output
messSchema.methods.toJSON = function(): Partial<IMess> {
  const messObject = this.toObject();
  delete messObject.__v;
  return messObject;
};

export const Mess = mongoose.model<IMessDocument>('Mess', messSchema);
