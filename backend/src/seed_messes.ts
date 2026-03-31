import mongoose from 'mongoose';
import { User } from './models/User';
import { Mess } from './models/Mess';
import { Menu } from './models/Menu';
import { config } from './config/config';

const seedMesses = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(config.MONGODB_URI);
    console.log('✅ Connected to MongoDB for mess seeding');

    // Find the owner user
    const owner = await User.findOne({ email: 'owner@mealhouse.com' });
    if (!owner) {
      console.error('❌ Owner user not found. Please run seed.ts first.');
      process.exit(1);
    }

    // Check if mess already exists
    let mess = await Mess.findOne({ ownerId: owner._id });
    if (mess) {
      console.log('ℹ️ Mess already exists for this owner, updating...');
    } else {
      // Create a test mess
      mess = await Mess.create({
        name: 'The Grand Meal House',
        ownerName: `${owner.firstName} ${owner.lastName}`,
        ownerId: owner._id,
        mobile: owner.mobile,
        description: 'Quality homemade food for students and professionals. Hygiene and taste guaranteed.',
        cuisineType: 'Maharashtrian / North Indian',
        address: '123, MIT Road, Kothrud, Pune - 411038',
        location: {
          type: 'Point',
          coordinates: [73.815, 18.507] // Sample Coordinates (Pune)
        },
        photos: [
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
          'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800&q=80'
        ],
        rating: 4.5,
        numReviews: 12,
        isApproved: true,
        isActive: true,
        operatingHours: [
          {
            day: 'Monday',
            isOpen: true,
            breakfast: { start: '08:00', end: '10:00' },
            lunch: { start: '12:30', end: '14:30' },
            dinner: { start: '19:30', end: '21:30' }
          },
          {
            day: 'Tuesday',
            isOpen: true,
            breakfast: { start: '08:00', end: '10:00' },
            lunch: { start: '12:30', end: '14:30' },
            dinner: { start: '19:30', end: '21:30' }
          }
        ]
      });
      console.log('✅ Created test mess for owner@mealhouse.com');
    }

    // Update or Create menu
    await Menu.findOneAndUpdate(
        { messId: mess._id },
        {
            messId: mess._id,
            items: [
                {
                    name: 'Special Veg Thali',
                    description: 'Full wholesome meal with variety of dishes',
                    price: 120,
                    category: 'Veg',
                    mealType: 'Lunch',
                    isAvailable: true,
                    ingredients: ['4 Chapati', 'Paneer Butter Masala', 'Dal Fry', 'Jeera Rice', 'Gulab Jamun', 'Salad', 'Papad'],
                    platesAvailable: 15,
                    image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&q=80'
                },
                {
                    name: 'Chicken Thali',
                    description: 'Spicy and delicious home-style chicken meal',
                    price: 220,
                    category: 'Non-Veg',
                    mealType: 'Dinner',
                    isAvailable: true,
                    ingredients: ['2 Bhakri', 'Chicken Curry', 'Chicken Sukka', 'Tambda Rassa', 'Pandhra Rassa', 'Rice', 'Onion'],
                    platesAvailable: 10,
                    image: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=800&q=80'
                },
                {
                    name: 'Poha Breakfast',
                    description: 'Light and healthy Maharashtrian breakfast',
                    price: 40,
                    category: 'Veg',
                    mealType: 'Breakfast',
                    isAvailable: true,
                    ingredients: ['Poha', 'Peanuts', 'Onion', 'Lemon', 'Coriander'],
                    platesAvailable: 25,
                    image: 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=800&q=80'
                }
            ]
        },
        { upsert: true, new: true }
    );
    console.log('✅ Updated test menu with real data fields');

    console.log('🎉 Mess seeding completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Mess seeding failed:', error);
    process.exit(1);
  }
};

seedMesses();
