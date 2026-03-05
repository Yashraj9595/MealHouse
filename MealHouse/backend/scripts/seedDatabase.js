const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import models
const User = require('../models/User');
const Mess = require('../models/Mess');
const MealGroup = require('../models/MealGroup');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/mealhouse', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Sample data
const sampleUsers = [
  {
    name: 'John Doe',
    email: 'john@example.com',
    phone: '9876543210',
    password: 'password123',
    role: 'user',
    address: {
      street: '123 Main St',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560001'
    }
  },
  {
    name: 'Jane Smith',
    email: 'jane@example.com',
    phone: '9876543211',
    password: 'password123',
    role: 'user',
    address: {
      street: '456 Oak Ave',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560002'
    }
  },
  {
    name: 'Raj Kumar',
    email: 'raj@example.com',
    phone: '9876543212',
    password: 'password123',
    role: 'mess_owner',
    address: {
      street: '789 Food St',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560003'
    }
  },
  {
    name: 'Admin User',
    email: 'admin@example.com',
    phone: '9876543213',
    password: 'admin123',
    role: 'admin',
    address: {
      street: '321 Admin Rd',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560004'
    }
  }
];

const sampleMesses = [
  {
    name: 'Annapurna Mess',
    description: 'Authentic South Indian meals with home-style cooking',
    cuisine: 'South Indian',
    image: 'https://images.unsplash.com/photo-1625398407796-82650a8c135f',
    price: '120',
    deliveryTime: '20-25 min',
    distance: '0.8 km',
    isVeg: true,
    contactPhone: '9876543210',
    address: {
      street: '123 Food Street',
      city: 'Bangalore',
      state: 'Karnataka',
      pincode: '560001'
    },
    location: {
      type: 'Point',
      coordinates: [77.5946, 12.9716] // Bangalore coordinates
    }
  },
  {
    name: 'Punjabi Dhaba',
    description: 'Traditional North Indian cuisine with rich flavors',
    cuisine: 'North Indian',
    image: 'https://images.unsplash.com/photo-1585032226651-759b368d7246',
    price: '150',
    deliveryTime: '25-30 min',
    distance: '1.2 km',
    isVeg: false,
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
    }
  },
  {
    name: 'Gujarati Thali House',
    description: 'Pure vegetarian Gujarati thalis with unlimited servings',
    cuisine: 'Gujarati',
    image: 'https://images.unsplash.com/photo-1601050690597-784da6911c5c',
    price: '130',
    deliveryTime: '30-35 min',
    distance: '1.5 km',
    isVeg: true,
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
    }
  },
  {
    name: 'Bengali Kitchen',
    description: 'Authentic Bengali dishes with mustard oil flavors',
    cuisine: 'Bengali',
    image: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624',
    price: '140',
    deliveryTime: '35-40 min',
    distance: '2.0 km',
    isVeg: false,
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
    }
  },
  {
    name: 'Chinese Wok',
    description: 'Street-style Chinese noodles and rice dishes',
    cuisine: 'Chinese',
    image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
    price: '160',
    deliveryTime: '15-20 min',
    distance: '0.5 km',
    isVeg: false,
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
    }
  },
  {
    name: 'Continental Cafe',
    description: 'European cuisine with pasta, pizza and more',
    cuisine: 'Continental',
    image: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
    price: '200',
    deliveryTime: '40-45 min',
    distance: '1.8 km',
    isVeg: false,
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
    }
  }
];

const sampleMealGroups = [
  // South Indian Meals
  {
    name: 'South Indian Lunch Thali',
    mess: null, // Will be set dynamically
    type: 'lunch',
    description: 'Complete South Indian meal with rice, sambar, rasam, curries',
    price: 120,
    items: [
      {
        name: 'Steamed Rice',
        description: 'Fluffy white rice',
        price: 40,
        isVeg: true
      },
      {
        name: 'Sambar',
        description: 'Lentil soup with vegetables',
        price: 25,
        isVeg: true
      },
      {
        name: 'Rasam',
        description: 'Tangy tamarind soup',
        price: 20,
        isVeg: true
      },
      {
        name: 'Mixed Vegetable Curry',
        description: 'Seasonal vegetables in coconut gravy',
        price: 35,
        isVeg: true
      }
    ],
    isFeatured: true
  },
  // North Indian Meals
  {
    name: 'North Indian Thali',
    mess: null,
    type: 'lunch',
    description: 'Traditional North Indian meal with roti, dal, vegetables',
    price: 150,
    items: [
      {
        name: 'Butter Roti',
        description: 'Soft buttered flatbread',
        price: 15,
        isVeg: true
      },
      {
        name: 'Dal Makhani',
        description: 'Creamy black lentils',
        price: 40,
        isVeg: true
      },
      {
        name: 'Paneer Butter Masala',
        description: 'Cottage cheese in creamy tomato gravy',
        price: 60,
        isVeg: true
      },
      {
        name: 'Jeera Rice',
        description: 'Basmati rice with cumin',
        price: 35,
        isVeg: true
      }
    ],
    isFeatured: true
  },
  // Chinese Meals
  {
    name: 'Chinese Combo',
    mess: null,
    type: 'dinner',
    description: 'Fried rice with noodles and manchurian',
    price: 160,
    items: [
      {
        name: 'Fried Rice',
        description: ' Indo-Chinese fried rice',
        price: 60,
        isVeg: false
      },
      {
        name: 'Hakka Noodles',
        description: 'Stir-fried noodles with vegetables',
        price: 50,
        isVeg: false
      },
      {
        name: 'Gobi Manchurian',
        description: 'Cauliflower in spicy gravy',
        price: 50,
        isVeg: true
      }
    ],
    isFeatured: false
  }
];

// Seed function
async function seedDatabase() {
  try {
    console.log('🌱 Starting database seeding...');

    // Clear existing data
    await User.deleteMany({});
    await Mess.deleteMany({});
    await MealGroup.deleteMany({});
    console.log('🗑️  Cleared existing data');

    // Insert users
    const users = await User.create(sampleUsers);
    console.log(`👥 Created ${users.length} users`);

    // Get mess owner user
    const messOwner = users.find(user => user.role === 'mess_owner');

    // Insert messes with owner
    const messesWithOwner = sampleMesses.map(mess => ({
      ...mess,
      owner: messOwner._id
    }));

    const messes = await Mess.create(messesWithOwner);
    console.log(`🏪 Created ${messes.length} messes`);

    // Insert meal groups
    const mealGroupsWithMess = sampleMealGroups.map((mealGroup, index) => ({
      ...mealGroup,
      mess: messes[index % messes.length]._id // Assign meal groups to messes
    }));

    const mealGroups = await MealGroup.create(mealGroupsWithMess);
    console.log(`🍱 Created ${mealGroups.length} meal groups`);

    console.log('✅ Database seeding completed successfully!');
    console.log('\n📋 Sample Login Credentials:');
    console.log('User: john@example.com / password123');
    console.log('Mess Owner: raj@example.com / password123');
    console.log('Admin: admin@example.com / admin123');

  } catch (error) {
    console.error('❌ Error seeding database:', error);
  } finally {
    mongoose.connection.close();
  }
}

// Run the seeding
seedDatabase();
