const mongoose = require('mongoose');

const mealItemSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Meal item name is required'],
    trim: true
  },
  description: {
    type: String,
    maxlength: [200, 'Description cannot exceed 200 characters']
  },
  price: {
    type: Number,
    required: [true, 'Price is required'],
    min: [0, 'Price cannot be negative']
  },
  isVeg: {
    type: Boolean,
    default: true
  },
  image: {
    type: String,
    default: null
  },
  ingredients: [String],
  allergens: [String],
  spicyLevel: {
    type: String,
    enum: ['mild', 'medium', 'hot', 'extra hot'],
    default: 'mild'
  }
});

const mealGroupSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Meal group name is required'],
    trim: true,
    maxlength: [100, 'Name cannot exceed 100 characters']
  },
  mess: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Mess',
    required: [true, 'Mess is required']
  },
  description: {
    type: String,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  type: {
    type: String,
    required: [true, 'Meal type is required'],
    enum: ['breakfast', 'lunch', 'dinner', 'snacks', 'beverages']
  },
  price: {
    type: Number,
    required: [true, 'Price is required'],
    min: [0, 'Price cannot be negative']
  },
  items: [mealItemSchema],
  image: {
    type: String,
    default: null
  },
  isAvailable: {
    type: Boolean,
    default: true
  },
  preparationTime: {
    type: String,
    default: '15-20 min'
  },
  servingSize: {
    type: String,
    default: '1 person'
  },
  calories: {
    type: Number,
    min: [0, 'Calories cannot be negative']
  },
  protein: {
    type: String,
    default: null
  },
  carbs: {
    type: String,
    default: null
  },
  fat: {
    type: String,
    default: null
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
  orderCount: {
    type: Number,
    default: 0
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  tags: [String],
  availableDays: {
    type: [String],
    enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
    default: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
  }
}, {
  timestamps: true
});

// Index for efficient queries
mealGroupSchema.index({ mess: 1, type: 1 });
mealGroupSchema.index({ isAvailable: 1, isFeatured: 1 });

// Virtual for rating
mealGroupSchema.virtual('ratingValue').get(function() {
  return this.rating.average;
});

// Ensure virtuals are included in JSON
mealGroupSchema.set('toJSON', { virtuals: true });
mealGroupSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('MealGroup', mealGroupSchema);
