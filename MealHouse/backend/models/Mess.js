const mongoose = require('mongoose');

const messSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Mess name is required'],
    trim: true,
    maxlength: [100, 'Name cannot exceed 100 characters']
  },
  owner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Mess owner is required']
  },
  description: {
    type: String,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  image: {
    type: String,
    default: 'https://images.unsplash.com/photo-1625398407796-82650a8c135f'
  },
  rating: {
    average: {
      type: Number,
      default: 4.0,
      min: [0, 'Rating cannot be less than 0'],
      max: [5, 'Rating cannot be more than 5']
    },
    count: {
      type: Number,
      default: 0
    }
  },
  cuisine: {
    type: String,
    required: [true, 'Cuisine type is required'],
    enum: ['South Indian', 'North Indian', 'Gujarati', 'Bengali', 'Chinese', 'Continental', 'Other']
  },
  deliveryTime: {
    type: String,
    required: [true, 'Delivery time is required'],
    default: '20-30 min'
  },
  distance: {
    type: String,
    required: [true, 'Distance is required'],
    default: '1.0 km'
  },
  price: {
    type: String,
    required: [true, 'Price is required'],
    default: '100'
  },
  isVeg: {
    type: Boolean,
    default: true
  },
  isActive: {
    type: Boolean,
    default: true
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      required: true,
      default: [77.2090, 28.6139] // Default Delhi coordinates
    }
  },
  address: {
    street: String,
    city: String,
    state: String,
    pincode: String
  },
  contactPhone: {
    type: String,
    required: [true, 'Contact phone is required'],
    match: [/^[0-9]{10}$/, 'Phone number must be 10 digits']
  },
  operatingHours: {
    opening: {
      type: String,
      default: '08:00'
    },
    closing: {
      type: String,
      default: '22:00'
    }
  }
}, {
  timestamps: true
});

// Create geospatial index for location-based queries
messSchema.index({ location: '2dsphere' });

// Virtual for rating
messSchema.virtual('ratingValue').get(function() {
  return this.rating.average;
});

// Ensure virtuals are included in JSON
messSchema.set('toJSON', { virtuals: true });
messSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Mess', messSchema);
