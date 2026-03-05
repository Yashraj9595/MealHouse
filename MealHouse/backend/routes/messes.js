const express = require('express');
const router = express.Router();
const Mess = require('../models/Mess');
const MealGroup = require('../models/MealGroup');
const User = require('../models/User');

// GET /api/messes - Get all messes
router.get('/', async (req, res) => {
  try {
    const { city, mealType, search, page = 1, limit = 10 } = req.query;
    
    // Build query
    let query = { isActive: true };
    
    if (city) {
      query['address.city'] = new RegExp(city, 'i');
    }
    
    if (search) {
      query.$or = [
        { name: new RegExp(search, 'i') },
        { cuisine: new RegExp(search, 'i') },
        { description: new RegExp(search, 'i') }
      ];
    }
    
    // Execute query with pagination
    const messes = await Mess.find(query)
      .populate('owner', 'name email phone')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ 'rating.average': -1 });
    
    const total = await Mess.countDocuments(query);
    
    res.json({
      success: true,
      message: 'Messes retrieved successfully',
      data: messes,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching messes:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch messes',
      error: error.message
    });
  }
});

// GET /api/messes/:id - Get mess details by ID
router.get('/:id', async (req, res) => {
  try {
    const mess = await Mess.findById(req.params.id)
      .populate('owner', 'name email phone');
    
    if (!mess) {
      return res.status(404).json({
        success: false,
        message: 'Mess not found'
      });
    }
    
    // Get meal groups for this mess
    const mealGroups = await MealGroup.find({ 
      mess: req.params.id, 
      isAvailable: true 
    }).sort({ type: 1 });
    
    res.json({
      success: true,
      message: 'Mess details retrieved successfully',
      data: {
        ...mess.toObject(),
        mealGroups
      }
    });
  } catch (error) {
    console.error('Error fetching mess details:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch mess details',
      error: error.message
    });
  }
});

// GET /api/messes/my - Get messes owned by current user
router.get('/my', async (req, res) => {
  try {
    // This would require authentication middleware
    const userId = req.user?.id; // Assuming auth middleware sets req.user
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }
    
    const messes = await Mess.find({ 
      owner: userId,
      isActive: true 
    }).populate('owner', 'name email phone');
    
    res.json({
      success: true,
      message: 'Your messes retrieved successfully',
      data: messes
    });
  } catch (error) {
    console.error('Error fetching user messes:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch your messes',
      error: error.message
    });
  }
});

// POST /api/messes - Create new mess
router.post('/', async (req, res) => {
  try {
    const messData = req.body;
    
    // Create new mess
    const mess = new Mess(messData);
    await mess.save();
    
    // Populate owner details
    await mess.populate('owner', 'name email phone');
    
    res.status(201).json({
      success: true,
      message: 'Mess created successfully',
      data: mess
    });
  } catch (error) {
    console.error('Error creating mess:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create mess',
      error: error.message
    });
  }
});

// PUT /api/messes/:id - Update mess
router.put('/:id', async (req, res) => {
  try {
    const mess = await Mess.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('owner', 'name email phone');
    
    if (!mess) {
      return res.status(404).json({
        success: false,
        message: 'Mess not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Mess updated successfully',
      data: mess
    });
  } catch (error) {
    console.error('Error updating mess:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update mess',
      error: error.message
    });
  }
});

// DELETE /api/messes/:id - Delete mess (soft delete)
router.delete('/:id', async (req, res) => {
  try {
    const mess = await Mess.findByIdAndUpdate(
      req.params.id,
      { isActive: false },
      { new: true }
    );
    
    if (!mess) {
      return res.status(404).json({
        success: false,
        message: 'Mess not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Mess deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting mess:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete mess',
      error: error.message
    });
  }
});

module.exports = router;
