import mongoose from 'mongoose';
import { User } from './models/User';
import { config } from './config/config';

const seedUsers = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(config.MONGODB_URI);
    console.log('✅ Connected to MongoDB for seeding');

    // Clear existing users? Or just update/create?
    // Let's create specific test users
    const users = [
      {
        email: 'admin@mealhouse.com',
        password: 'admin123',
        firstName: 'System',
        lastName: 'Admin',
        mobile: '1234567890',
        role: 'admin',
        isEmailVerified: true,
        isMobileVerified: true,
        isActive: true,
      },
      {
        email: 'owner@mealhouse.com',
        password: 'owner123',
        firstName: 'Mess',
        lastName: 'Owner',
        mobile: '9876543210',
        role: 'manager',
        isEmailVerified: true,
        isMobileVerified: true,
        isActive: true,
      },
      {
        email: 'user@mealhouse.com',
        password: 'user123',
        firstName: 'Regular',
        lastName: 'User',
        mobile: '5555555555',
        role: 'user',
        isEmailVerified: true,
        isMobileVerified: true,
        isActive: true,
      }
    ];

    for (const userData of users) {
      const existingUser = await User.findOne({ email: userData.email });
      if (existingUser) {
        console.log(`ℹ️ Updating existing user: ${userData.email}`);
        existingUser.set(userData);
        await existingUser.save();
        console.log(`✅ Updated ${userData.role}: ${userData.email}`);
      } else {
        await User.create(userData);
        console.log(`✅ Created ${userData.role}: ${userData.email}`);
      }
    }

    console.log('🎉 Seeding completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
};

seedUsers();
