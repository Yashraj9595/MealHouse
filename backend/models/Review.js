const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    mess: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Mess',
        required: true
    },
    order: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Order',
        required: true
    },
    rating: {
        type: Number,
        required: [true, 'Please provide a rating'],
        min: [1, 'Rating must be at least 1'],
        max: [5, 'Rating cannot be more than 5']
    },
    comment: {
        type: String,
        maxlength: [500, 'Comment cannot be more than 500 characters']
    },
    foodQuality: {
        type: Number,
        min: 1,
        max: 5
    },
    packaging: {
        type: Number,
        min: 1,
        max: 5
    },
    valueForMoney: {
        type: Number,
        min: 1,
        max: 5
    },
    images: [{
        url: String,
        public_id: String
    }],
    isVerifiedPurchase: {
        type: Boolean,
        default: true
    },
    helpfulCount: {
        type: Number,
        default: 0
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

// Ensure one review per order
reviewSchema.index({ user: 1, order: 1 }, { unique: true });
reviewSchema.index({ mess: 1, createdAt: -1 });

// Update mess rating after review is saved
reviewSchema.post('save', async function () {
    const Mess = mongoose.model('Mess');
    const stats = await this.constructor.aggregate([
        {
            $match: { mess: this.mess }
        },
        {
            $group: {
                _id: '$mess',
                averageRating: { $avg: '$rating' },
                count: { $sum: 1 }
            }
        }
    ]);

    if (stats.length > 0) {
        await Mess.findByIdAndUpdate(this.mess, {
            'rating.average': Math.round(stats[0].averageRating * 10) / 10,
            'rating.count': stats[0].count
        });
    }
});

module.exports = mongoose.model('Review', reviewSchema);
