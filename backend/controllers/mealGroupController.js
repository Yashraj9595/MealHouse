const MealGroup = require('../models/MealGroup');
const Mess = require('../models/Mess');

// @desc    Get all meal groups for a mess
// @route   GET /api/messes/:messId/mealgroups
// @access  Public
exports.getMealGroups = async (req, res, next) => {
    try {
        const { messId } = req.params;
        const { mealType, category, date } = req.query;

        let query = {
            mess: messId,
            isActive: true,
            validUntil: { $gte: new Date() }
        };

        if (mealType) {
            query.mealType = mealType;
        }

        if (category) {
            query.category = category;
        }

        if (date) {
            const searchDate = new Date(date);
            searchDate.setHours(0, 0, 0, 0);
            const nextDay = new Date(searchDate);
            nextDay.setDate(nextDay.getDate() + 1);

            query.date = {
                $gte: searchDate,
                $lt: nextDay
            };
        }

        const mealGroups = await MealGroup.find(query)
            .populate('mess', 'name address mealType')
            .sort('mealType');

        res.status(200).json({
            success: true,
            count: mealGroups.length,
            data: mealGroups
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get single meal group
// @route   GET /api/mealgroups/:id
// @access  Public
exports.getMealGroup = async (req, res, next) => {
    try {
        const mealGroup = await MealGroup.findById(req.params.id)
            .populate('mess', 'name address contact mealType');

        if (!mealGroup) {
            return res.status(404).json({
                success: false,
                message: 'Meal group not found'
            });
        }

        res.status(200).json({
            success: true,
            data: mealGroup
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Create meal group
// @route   POST /api/messes/:messId/mealgroups
// @access  Private (Mess Owner, Admin)
exports.createMealGroup = async (req, res, next) => {
    try {
        const { messId } = req.params;

        // Verify mess exists and user owns it
        const mess = await Mess.findById(messId);

        if (!mess) {
            return res.status(404).json({
                success: false,
                message: 'Mess not found'
            });
        }

        if (mess.owner.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to add meal groups to this mess'
            });
        }

        // Add mess to meal group
        req.body.mess = messId;

        // Set validUntil to end of day if not provided
        if (!req.body.validUntil) {
            const endOfDay = new Date();
            endOfDay.setHours(23, 59, 59, 999);
            req.body.validUntil = endOfDay;
        }

        const mealGroup = await MealGroup.create(req.body);

        res.status(201).json({
            success: true,
            message: 'Meal group created successfully',
            data: mealGroup
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Update meal group
// @route   PUT /api/mealgroups/:id
// @access  Private (Mess Owner, Admin)
exports.updateMealGroup = async (req, res, next) => {
    try {
        let mealGroup = await MealGroup.findById(req.params.id).populate('mess');

        if (!mealGroup) {
            return res.status(404).json({
                success: false,
                message: 'Meal group not found'
            });
        }

        // Check ownership
        if (mealGroup.mess.owner.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to update this meal group'
            });
        }

        // Prevent changing mess
        delete req.body.mess;

        mealGroup = await MealGroup.findByIdAndUpdate(req.params.id, req.body, {
            new: true,
            runValidators: true
        });

        res.status(200).json({
            success: true,
            message: 'Meal group updated successfully',
            data: mealGroup
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete meal group
// @route   DELETE /api/mealgroups/:id
// @access  Private (Mess Owner, Admin)
exports.deleteMealGroup = async (req, res, next) => {
    try {
        const mealGroup = await MealGroup.findById(req.params.id).populate('mess');

        if (!mealGroup) {
            return res.status(404).json({
                success: false,
                message: 'Meal group not found'
            });
        }

        // Check ownership
        if (mealGroup.mess.owner.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to delete this meal group'
            });
        }

        // Soft delete
        mealGroup.isActive = false;
        await mealGroup.save();

        res.status(200).json({
            success: true,
            message: 'Meal group deleted successfully',
            data: {}
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Update tiffin availability
// @route   PUT /api/mealgroups/:id/availability
// @access  Private (Mess Owner, Admin)
exports.updateAvailability = async (req, res, next) => {
    try {
        const { totalTiffins, availableTiffins } = req.body;

        const mealGroup = await MealGroup.findById(req.params.id).populate('mess');

        if (!mealGroup) {
            return res.status(404).json({
                success: false,
                message: 'Meal group not found'
            });
        }

        // Check ownership
        if (mealGroup.mess.owner.toString() !== req.user.id && req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to update this meal group'
            });
        }

        if (totalTiffins !== undefined) {
            mealGroup.totalTiffins = totalTiffins;
        }

        if (availableTiffins !== undefined) {
            mealGroup.availableTiffins = Math.min(availableTiffins, mealGroup.totalTiffins);
        }

        await mealGroup.save();

        res.status(200).json({
            success: true,
            message: 'Availability updated successfully',
            data: mealGroup
        });
    } catch (error) {
        next(error);
    }
};
