const express = require('express');
const router = express.Router();
const MealGroup = require('../models/MealGroup');
const Mess = require('../models/Mess');

// GET /api/mealgroups - Get all meal groups
router.get('/', async (req, res) => {
  try {
    const { mess, type, isAvailable, page = 1, limit = 20 } = req.query;
    
    // Build query
    let query = {};
    
    if (mess) {
      query.mess = mess;
    }
    
    if (type) {
      query.type = type;
    }
    
    if (isAvailable !== undefined) {
      query.isAvailable = isAvailable === 'true';
    }
    
    // Execute query with pagination
    const mealGroups = await MealGroup.find(query)
      .populate('mess', 'name cuisine rating image')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ isFeatured: -1, rating: -1 });
    
    const total = await MealGroup.countDocuments(query);
    
    res.json({
      success: true,
      message: 'Meal groups retrieved successfully',
      data: mealGroups,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching meal groups:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch meal groups',
      error: error.message
    });
  }
});

// GET /api/mealgroups/featured - Get featured meal groups
router.get('/featured', async (req, res) => {
  try {
    const mealGroups = await MealGroup.find({ 
      isAvailable: true, 
      isFeatured: true 
    })
      .populate('mess', 'name cuisine rating image')
      .limit(10)
      .sort({ rating: -1 });
    
    res.json({
      success: true,
      message: 'Featured meal groups retrieved successfully',
      data: mealGroups
    });
  } catch (error) {
    console.error('Error fetching featured meal groups:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch featured meal groups',
      error: error.message
    });
  }
});

// GET /api/mealgroups/:id - Get meal group by ID
router.get('/:id', async (req, res) => {
  try {
    const mealGroup = await MealGroup.findById(req.params.id)
      .populate('mess', 'name cuisine rating image address contactPhone');
    
    if (!mealGroup) {
      return res.status(404).json({
        success: false,
        message: 'Meal group not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Meal group retrieved successfully',
      data: mealGroup
    });
  } catch (error) {
    console.error('Error fetching meal group:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch meal group',
      error: error.message
    });
  }
});

// POST /api/mealgroups - Create new meal group
router.post('/', async (req, res) => {
  try {
    const mealGroupData = req.body;
    
    // Create new meal group
    const mealGroup = new MealGroup(mealGroupData);
    await mealGroup.save();
    
    // Populate mess details
    await mealGroup.populate('mess', 'name cuisine rating image');
    
    res.status(201).json({
      success: true,
      message: 'Meal group created successfully',
      data: mealGroup
    });
  } catch (error) {
    console.error('Error creating meal group:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create meal group',
      error: error.message
    });
  }
});

// PUT /api/mealgroups/:id - Update meal group
router.put('/:id', async (req, res) => {
  try {
    const mealGroup = await MealGroup.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('mess', 'name cuisine rating image');
    
    if (!mealGroup) {
      return res.status(404).json({
        success: false,
        message: 'Meal group not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Meal group updated successfully',
      data: mealGroup
    });
  } catch (error) {
    console.error('Error updating meal group:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update meal group',
      error: error.message
    });
  }
});

// DELETE /api/mealgroups/:id - Delete meal group
router.delete('/:id', async (req, res) => {
  try {
    const mealGroup = await MealGroup.findByIdAndDelete(req.params.id);
    
    if (!mealGroup) {
      return res.status(404).json({
        success: false,
        message: 'Meal group not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Meal group deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting meal group:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete meal group',
      error: error.message
    });
  }
});

module.exports = router;
