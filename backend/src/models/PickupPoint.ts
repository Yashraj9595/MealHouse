import mongoose, { Schema, Document } from 'mongoose';

export interface IPickupPoint extends Document {
  name: string;
  address: string;
  location: {
    type: string;
    coordinates: [number, number]; // [longitude, latitude]
  };
  operatingHours: {
    breakfast: { isActive: boolean; startTime: string; endTime: string };
    lunch: { isActive: boolean; startTime: string; endTime: string };
    dinner: { isActive: boolean; startTime: string; endTime: string };
  };
  maxOrders?: number;
  instructions?: string;
  contacts: {
    name: string;
    phone: string;
  }[];
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const pickupPointSchema: Schema = new Schema(
  {
    name: {
      type: String,
      required: [true, 'Please provide a name for the pickup point'],
      trim: true,
      maxlength: [100, 'Name cannot be more than 100 characters']
    },
    address: {
      type: String,
      required: [true, 'Please provide an address']
    },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point'
      },
      coordinates: {
        type: [Number],
        required: [true, 'Please provide coordinates [longitude, latitude]']
      }
    },
    operatingHours: {
      breakfast: {
        isActive: { type: Boolean, default: false },
        startTime: { type: String, default: '07:00' },
        endTime: { type: String, default: '09:00' }
      },
      lunch: {
        isActive: { type: Boolean, default: true },
        startTime: { type: String, default: '12:00' },
        endTime: { type: String, default: '14:00' }
      },
      dinner: {
        isActive: { type: Boolean, default: true },
        startTime: { type: String, default: '19:00' },
        endTime: { type: String, default: '21:00' }
      }
    },
    maxOrders: {
      type: Number,
      default: 50
    },
    instructions: {
      type: String,
      trim: true
    },
    contacts: [
      {
        name: { type: String, trim: true },
        phone: { type: String, trim: true }
      }
    ],
    isActive: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

// Index for geo-spatial queries
pickupPointSchema.index({ location: '2dsphere' });

export const PickupPoint = mongoose.model<IPickupPoint>('PickupPoint', pickupPointSchema);
