const Mess = require('../models/Mess');
const MealGroup = require('../models/MealGroup');

// @desc    Get all messes
// @route   GET /api/messes
// @access  Public
exports.getMesses = async (req, res, next) => {
    try {
        const { city, mealType, search, lat, lng, radius = 10 } = req.query;

        let query = { isActive: true };

        // Filter by city
        if (city) {
            query['address.city'] = new RegExp(city, 'i');
        }

        // Filter by meal type
        if (mealType && mealType !== 'all') {
            query.mealType = { $in: [mealType, 'both'] };
        }

        // Search by name
        if (search) {
            query.name = new RegExp(search, 'i');
        }

        // Location-based search
        if (lat && lng) {
            query['address.coordinates'] = {
                $near: {
                    $geometry: {
                        type: 'Point',
                        coordinates: [parseFloat(lng), parseFloat(lat)]
                    },
                    $maxDistance: radius * 1000 // Convert km to meters
                }
            };
        }

        const messes = await Mess.find(query)
            .populate('owner', 'name email phone')
            .sort('-createdAt');

        res.status(200).json({
            success: true,
            count: messes.length,
            data: messes
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get single mess
// @route   GET /api/messes/:id
// @access  Public
exports.getMess = async (req, res, next) => {
    try {
        const mess = await Mess.findById(req.params.id)
            .populate('owner', 'name email phone');

        if (!mess) {
            return res.status(404).json({
                success: false,
                message: 'Mess not found'
            });
        }

        // Get active meal groups for today
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const mealGroups = await MealGroup.find({
            mess: mess._id,
            isActive: true,
            validUntil: { $gte: new Date() }
        }).sort('mealType');

        res.status(200).json({
            success: true,
            data: {
                ...mess.toObject(),
                mealGroups
            }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Create new mess
// @route   POST /api/messes
// @access  Private (Mess Owner, Admin)
exports.createMess = async (req, res, next) => {
    try {
        // Add user as owner
        req.body.owner = req.user.id;

        // Check if user already has a mess (optional - remove if multiple messes allowed)
        const existingMess = await Mess.findOne({ owner: req.user.id });
        if (existingMess && req.user.role !== 'admin') {
            return res.status(400).json({
                success: false,
                message: 'You already have a registered mess'
            });
        }

        const mess = await Mess.create(req.body);

        res.status(201).json({
            success: true,
            message: 'Mess created successfully',
            data: mess
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Update mess
// @route   PUT /api/messes/:id
// @access  Private (Owner, Admin)
exports.updateMess = async (req, res, next) => {
    try {
        let mess = await Mess.findById(req.params.id);

        if (!mess) {
            return res.status(404).json({
                success: false,
                message: 'Mess not found'
            });
        }

        // Check ownership
        if (mess.owner.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to update this mess'
            });
        }

        // Prevent changing owner
        delete req.body.owner;

        mess = await Mess.findByIdAndUpdate(req.params.id, req.body, {
            new: true,
            runValidators: true
        });

        res.status(200).json({
            success: true,
            message: 'Mess updated successfully',
            data: mess
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete mess
// @route   DELETE /api/messes/:id
// @access  Private (Owner, Admin)
exports.deleteMess = async (req, res, next) => {
    try {
        const mess = await Mess.findById(req.params.id);

        if (!mess) {
            return res.status(404).json({
                success: false,
                message: 'Mess not found'
            });
        }

        // Check ownership
        if (mess.owner.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to delete this mess'
            });
        }

        // Soft delete - just deactivate
        mess.isActive = false;
        await mess.save();

        res.status(200).json({
            success: true,
            message: 'Mess deleted successfully',
            data: {}
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get my mess (for mess owner)
// @route   GET /api/messes/my/mess
// @access  Private (Mess Owner)
exports.getMyMess = async (req, res, next) => {
    try {
        const mess = await Mess.findOne({ owner: req.user.id });

        if (!mess) {
            return res.status(404).json({
                success: false,
                message: 'No mess found for this user'
            });
        }

        res.status(200).json({
            success: true,
            data: mess
        });
    } catch (error) {
        next(error);
    }
};
