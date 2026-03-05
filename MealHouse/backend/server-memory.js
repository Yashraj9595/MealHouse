const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const app = express();
const PORT = process.env.PORT || 5001;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: ['http://localhost:3000', 'http://10.87.156.74:3000'],
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Body parser middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// In-memory data (for testing without MongoDB)
let messes = [
  {
    _id: '1',
    name: 'Annapurna Mess',
    owner: {
      _id: 'owner1',
      name: 'Raj Kumar',
      email: 'raj@example.com',
      phone: '9876543212'
    },
    description: 'Authentic South Indian meals with home-style cooking',
    image: 'https://images.unsplash.com/photo-1625398407796-82650a8c135f',
    rating: { average: 4.5, count: 128 },
    cuisine: 'South Indian',
    deliveryTime: '20-25 min',
    distance: '0.8 km',
    price: '120',
    isVeg: true,
    isActive: true,
    contactPhone: '9876543210',
    address: {
      street: '123 Food Street',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560001'
    },
    location: {
      type: 'Point',
      coordinates: [77.5946, 12.9716]
    },
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: '2',
    name: 'Punjabi Dhaba',
    owner: {
      _id: 'owner2',
      name: 'Amit Singh',
      email: 'amit@example.com',
      phone: '9876543213'
    },
    description: 'Traditional North Indian cuisine with rich flavors',
    image: 'https://images.unsplash.com/photo-1585032226651-759b368d7246',
    rating: { average: 4.2, count: 95 },
    cuisine: 'North Indian',
    deliveryTime: '25-30 min',
    distance: '1.2 km',
    price: '150',
    isVeg: false,
    isActive: true,
    contactPhone: '9876543211',
    address: {
      street: '456 Spice Lane',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560002'
    },
    location: {
      type: 'Point',
      coordinates: [77.5856, 12.9726]
    },
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: '3',
    name: 'Gujarati Thali House',
    owner: {
      _id: 'owner3',
      name: 'Priya Shah',
      email: 'priya@example.com',
      phone: '9876543214'
    },
    description: 'Pure vegetarian Gujarati thalis with unlimited servings',
    image: 'https://images.unsplash.com/photo-1601050690597-784da6911c5c',
    rating: { average: 4.7, count: 76 },
    cuisine: 'Gujarati',
    deliveryTime: '30-35 min',
    distance: '1.5 km',
    price: '130',
    isVeg: true,
    isActive: true,
    contactPhone: '9876543212',
    address: {
      street: '789 Sweet Road',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560003'
    },
    location: {
      type: 'Point',
      coordinates: [77.5766, 12.9736]
    },
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: '4',
    name: 'Bengali Kitchen',
    owner: {
      _id: 'owner4',
      name: 'Sourav Banerjee',
      email: 'sourav@example.com',
      phone: '9876543215'
    },
    description: 'Authentic Bengali dishes with mustard oil flavors',
    image: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624',
    rating: { average: 4.3, count: 62 },
    cuisine: 'Bengali',
    deliveryTime: '35-40 min',
    distance: '2.0 km',
    price: '140',
    isVeg: false,
    isActive: true,
    contactPhone: '9876543213',
    address: {
      street: '321 Fish Market',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560004'
    },
    location: {
      type: 'Point',
      coordinates: [77.5676, 12.9746]
    },
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: '5',
    name: 'Chinese Wok',
    owner: {
      _id: 'owner5',
      name: 'David Chen',
      email: 'david@example.com',
      phone: '9876543216'
    },
    description: 'Street-style Chinese noodles and rice dishes',
    image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
    rating: { average: 4.1, count: 89 },
    cuisine: 'Chinese',
    deliveryTime: '15-20 min',
    distance: '0.5 km',
    price: '160',
    isVeg: false,
    isActive: true,
    contactPhone: '9876543214',
    address: {
      street: '654 Noodle Street',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560005'
    },
    location: {
      type: 'Point',
      coordinates: [77.5986, 12.9706]
    },
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: '6',
    name: 'Continental Cafe',
    owner: {
      _id: 'owner6',
      name: 'Marco Rossi',
      email: 'marco@example.com',
      phone: '9876543217'
    },
    description: 'European cuisine with pasta, pizza and more',
    image: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
    rating: { average: 4.6, count: 54 },
    cuisine: 'Continental',
    deliveryTime: '40-45 min',
    distance: '1.8 km',
    price: '200',
    isVeg: false,
    isActive: true,
    contactPhone: '9876543215',
    address: {
      street: '987 Pasta Plaza',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560006'
    },
    location: {
      type: 'Point',
      coordinates: [77.6096, 12.9696]
    },
    createdAt: new Date(),
    updatedAt: new Date()
  }
];

// Mock users
const users = [
  {
    _id: 'user1',
    name: 'John Doe',
    email: 'john@example.com',
    phone: '9876543210',
    role: 'user'
  },
  {
    _id: 'user2',
    name: 'Jane Smith',
    email: 'jane@example.com',
    phone: '9876543211',
    role: 'user'
  }
];

// Routes
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'MealHouse API is running (In-Memory Mode)',
    timestamp: new Date().toISOString(),
    environment: 'development-memory',
    dataCount: {
      messes: messes.length,
      users: users.length
    }
  });
});

// GET /api/messes - Get all messes
app.get('/api/messes', (req, res) => {
  try {
    const { city, search, page = 1, limit = 10 } = req.query;
    
    let filteredMesses = [...messes];
    
    if (city) {
      filteredMesses = filteredMesses.filter(mess => 
        mess.address.city.toLowerCase().includes(city.toLowerCase())
      );
    }
    
    if (search) {
      filteredMesses = filteredMesses.filter(mess => 
        mess.name.toLowerCase().includes(search.toLowerCase()) ||
        mess.cuisine.toLowerCase().includes(search.toLowerCase())
      );
    }
    
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedMesses = filteredMesses.slice(startIndex, endIndex);
    
    res.json({
      success: true,
      message: 'Messes retrieved successfully',
      data: paginatedMesses,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: filteredMesses.length,
        pages: Math.ceil(filteredMesses.length / limit)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch messes',
      error: error.message
    });
  }
});

// GET /api/messes/:id - Get mess details
app.get('/api/messes/:id', (req, res) => {
  try {
    const mess = messes.find(m => m._id === req.params.id);
    
    if (!mess) {
      return res.status(404).json({
        success: false,
        message: 'Mess not found'
      });
    }
    
    // Add mock meal groups
    const messWithMealGroups = {
      ...mess,
      mealGroups: [
        {
          _id: 'mg1',
          name: 'Regular Thali',
          type: 'lunch',
          price: 120,
          isAvailable: true,
          items: [
            { name: 'Rice', price: 30 },
            { name: 'Dal', price: 25 },
            { name: 'Sabzi', price: 35 },
            { name: 'Roti', price: 30 }
          ]
        }
      ]
    };
    
    res.json({
      success: true,
      message: 'Mess details retrieved successfully',
      data: messWithMealGroups
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch mess details',
      error: error.message
    });
  }
});

// POST /api/auth/login - Mock login
app.post('/api/auth/login', (req, res) => {
  try {
    const { email, password } = req.body;
    
    const user = users.find(u => u.email === email);
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }
    
    res.json({
      success: true,
      message: 'Login successful',
      token: 'mock-jwt-token-' + user._id,
      user: user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Login failed',
      error: error.message
    });
  }
});

// GET /api/auth/me - Mock get current user
app.get('/api/auth/me', (req, res) => {
  res.json({
    success: true,
    message: 'User profile retrieved successfully',
    data: users[0] // Return first user as mock
  });
});

// GET /api/mealgroups - Mock meal groups
app.get('/api/mealgroups', (req, res) => {
  res.json({
    success: true,
    message: 'Meal groups retrieved successfully',
    data: []
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
    path: req.originalUrl
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 MealHouse API server running on port ${PORT}`);
  console.log(`📱 Local: http://localhost:${PORT}`);
  console.log(`📱 Network: http://10.87.156.74:${PORT}`);
  console.log(`🔗 Health check: http://10.87.156.74:${PORT}/api/health`);
  console.log(`💾 Using: In-Memory Database (No MongoDB required)`);
  console.log(`📊 Data: ${messes.length} messes loaded`);
});
