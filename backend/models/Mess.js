const mongoose = require('mongoose');

const messSchema = new mongoose.Schema({
    owner: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    name: {
        type: String,
        required: [true, 'Please provide mess name'],
        trim: true,
        maxlength: [100, 'Mess name cannot be more than 100 characters']
    },
    description: {
        type: String,
        maxlength: [500, 'Description cannot be more than 500 characters']
    },
    address: {
        street: {
            type: String,
            required: [true, 'Please provide street address']
        },
        area: String,
        city: {
            type: String,
            required: [true, 'Please provide city']
        },
        state: {
            type: String,
            required: [true, 'Please provide state']
        },
        pincode: {
            type: String,
            required: [true, 'Please provide pincode'],
            match: [/^[0-9]{6}$/, 'Please provide a valid 6-digit pincode']
        },
        coordinates: {
            latitude: Number,
            longitude: Number
        }
    },
    contact: {
        phone: {
            type: String,
            required: [true, 'Please provide contact number'],
            match: [/^[0-9]{10}$/, 'Please provide a valid 10-digit phone number']
        },
        email: {
            type: String,
            match: [
                /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
                'Please provide a valid email'
            ]
        },
        whatsapp: String
    },
    mealType: {
        type: String,
        enum: ['veg', 'non-veg', 'both'],
        required: [true, 'Please specify meal type']
    },
    images: [{
        url: String,
        public_id: String
    }],
    coverImage: {
        url: String,
        public_id: String
    },
    rating: {
        average: {
            type: Number,
            default: 0,
            min: 0,
            max: 5
        },
        count: {
            type: Number,
            default: 0
        }
    },
    openingHours: {
        breakfast: {
            start: String,
            end: String
        },
        lunch: {
            start: String,
            end: String
        },
        dinner: {
            start: String,
            end: String
        }
    },
    isActive: {
        type: Boolean,
        default: true
    },
    isVerified: {
        type: Boolean,
        default: false
    },
    totalOrders: {
        type: Number,
        default: 0
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

// Virtual populate for meal groups
messSchema.virtual('mealGroups', {
    ref: 'MealGroup',
    localField: '_id',
    foreignField: 'mess',
    justOne: false
});

// Index for location-based queries
messSchema.index({ 'address.coordinates': '2dsphere' });

module.exports = mongoose.model('Mess', messSchema);
