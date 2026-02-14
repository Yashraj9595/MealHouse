const mongoose = require('mongoose');

const mealItemSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    quantity: {
        type: String,
        default: '1 serving'
    },
    description: String
}, { _id: false });

const mealGroupSchema = new mongoose.Schema({
    mess: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Mess',
        required: true
    },
    name: {
        type: String,
        required: [true, 'Please provide meal group name'],
        trim: true,
        maxlength: [100, 'Meal group name cannot be more than 100 characters']
    },
    description: {
        type: String,
        maxlength: [300, 'Description cannot be more than 300 characters']
    },
    mealType: {
        type: String,
        enum: ['breakfast', 'lunch', 'dinner', 'snacks'],
        required: [true, 'Please specify meal type']
    },
    category: {
        type: String,
        enum: ['veg', 'non-veg'],
        required: [true, 'Please specify category']
    },
    items: {
        type: [mealItemSchema],
        validate: {
            validator: function (items) {
                return items && items.length > 0;
            },
            message: 'Please add at least one meal item'
        }
    },
    price: {
        type: Number,
        required: [true, 'Please provide price per tiffin'],
        min: [0, 'Price cannot be negative']
    },
    totalTiffins: {
        type: Number,
        required: [true, 'Please specify total available tiffins'],
        min: [0, 'Total tiffins cannot be negative']
    },
    availableTiffins: {
        type: Number,
        required: true,
        min: [0, 'Available tiffins cannot be negative']
    },
    image: {
        url: String,
        public_id: String
    },
    isActive: {
        type: Boolean,
        default: true
    },
    date: {
        type: Date,
        default: Date.now
    },
    validUntil: {
        type: Date,
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

// Set availableTiffins to totalTiffins when creating new meal group
mealGroupSchema.pre('save', function (next) {
    if (this.isNew) {
        this.availableTiffins = this.totalTiffins;
    }
    next();
});

// Index for efficient queries
mealGroupSchema.index({ mess: 1, date: -1 });
mealGroupSchema.index({ validUntil: 1 });

// Method to check if tiffins are available
mealGroupSchema.methods.hasAvailableTiffins = function (quantity) {
    return this.availableTiffins >= quantity;
};

// Method to reduce available tiffins
mealGroupSchema.methods.reduceTiffins = async function (quantity) {
    if (this.availableTiffins >= quantity) {
        this.availableTiffins -= quantity;
        await this.save();
        return true;
    }
    return false;
};

// Method to restore tiffins (for order cancellation)
mealGroupSchema.methods.restoreTiffins = async function (quantity) {
    this.availableTiffins = Math.min(this.availableTiffins + quantity, this.totalTiffins);
    await this.save();
};

module.exports = mongoose.model('MealGroup', mealGroupSchema);
