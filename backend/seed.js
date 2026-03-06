const mongoose = require('mongoose');
const User = require('./models/User');
const Mess = require('./models/Mess');
const MealGroup = require('./models/MealGroup');
require('dotenv').config();

const seedDatabase = async () => {
    try {
        // Connect to MongoDB
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB');

        // Clear existing data
        await User.deleteMany({});
        await Mess.deleteMany({});
        await MealGroup.deleteMany({});
        console.log('🗑️  Cleared existing data');

        // Create Admin User
        const admin = await User.create({
            name: 'Admin User',
            email: 'admin@messapp.com',
            phone: '9999999999',
            password: 'admin123',
            role: 'admin',
            address: {
                street: '123 Admin Street',
                city: 'Mumbai',
                state: 'Maharashtra',
                pincode: '400001',
                coordinates: {
                    latitude: 19.0760,
                    longitude: 72.8777
                }
            }
        });
        console.log('✅ Created Admin User:', admin.email);

        // Create Mess Owner User
        const messOwner = await User.create({
            name: 'Rajesh Kumar',
            email: 'rajesh@messowner.com',
            phone: '9876543210',
            password: 'owner123',
            role: 'mess_owner',
            address: {
                street: '456 Owner Lane',
                city: 'Mumbai',
                state: 'Maharashtra',
                pincode: '400002',
                coordinates: {
                    latitude: 19.0896,
                    longitude: 72.8656
                }
            }
        });
        console.log('✅ Created Mess Owner:', messOwner.email);

        // Create Regular User
        const regularUser = await User.create({
            name: 'Priya Sharma',
            email: 'priya@user.com',
            phone: '9876543211',
            password: 'user123',
            role: 'user',
            address: {
                street: '789 User Road',
                city: 'Mumbai',
                state: 'Maharashtra',
                pincode: '400003',
                coordinates: {
                    latitude: 19.1136,
                    longitude: 72.8697
                }
            }
        });
        console.log('✅ Created Regular User:', regularUser.email);

        // Create Additional Users
        const user2 = await User.create({
            name: 'Amit Patel',
            email: 'amit@user.com',
            phone: '9876543213',
            password: 'user123',
            role: 'user',
            address: {
                street: '123, Nehru Nagar',
                city: 'Mumbai',
                state: 'Maharashtra',
                pincode: '400069',
                coordinates: {
                    latitude: 19.0760,
                    longitude: 72.8777
                }
            }
        });
        console.log('✅ Created User 2:', user2.email);

        const user3 = await User.create({
            name: 'Sneha Reddy',
            email: 'sneha@user.com',
            phone: '9876543214',
            password: 'user123',
            role: 'user',
            address: {
                street: '456, Shivaji Park',
                city: 'Mumbai',
                state: 'Maharashtra',
                pincode: '400028',
                coordinates: {
                    latitude: 19.0180,
                    longitude: 72.8420
                }
            }
        });
        console.log('✅ Created User 3:', user3.email);

        const messOwner2 = await User.create({
            name: 'Vijay Kumar',
            email: 'vijay@messowner.com',
            phone: '9876543215',
            password: 'owner123',
            role: 'mess_owner',
            address: {
                street: '789, Linking Road',
                city: 'Mumbai',
                state: 'Maharashtra',
                pincode: '400052',
                coordinates: {
                    latitude: 19.0596,
                    longitude: 72.8295
                }
            }
        });
        console.log('✅ Created Mess Owner 2:', messOwner2.email);

        // Create Mess 1: Annapurna Mess (Veg)
        const mess1 = await Mess.create({
            owner: messOwner._id,
            name: 'Annapurna Mess',
            description: 'Pure vegetarian homestyle meals with authentic Indian flavors. Serving fresh, healthy food daily.',
            address: {
                street: '12, MG Road',
                area: 'Andheri West',
                city: 'Mumbai',
                state: 'Maharashtra',
                pincode: '400058',
                coordinates: {
                    latitude: 19.1136,
                    longitude: 72.8697
                }
            },
            contact: {
                phone: '9876543210',
                email: 'annapurna@mess.com',
                whatsapp: '9876543210'
            },
            mealType: 'veg',
            openingHours: {
                breakfast: { start: '07:00', end: '10:00' },
                lunch: { start: '12:00', end: '15:00' },
                dinner: { start: '19:00', end: '22:00' }
            },
            rating: {
                average: 4.5,
                count: 120
            },
            isActive: true,
            isVerified: true
        });
        console.log('✅ Created Mess 1:', mess1.name);

        // Create Mess 2: Spice Garden (Both)
        const mess2 = await Mess.create({
            owner: messOwner._id,
            name: 'Spice Garden',
            description: 'Delicious veg and non-veg meals. Famous for our chicken biryani and dal tadka.',
            address: {
                street: '45, Station Road',
                area: 'Bandra East',
                city: 'Mumbai',
                state: 'Maharashtra',
                pincode: '400051',
                coordinates: {
                    latitude: 19.0596,
                    longitude: 72.8295
                }
            },
            contact: {
                phone: '9876543211',
                email: 'spicegarden@mess.com',
                whatsapp: '9876543211'
            },
            mealType: 'both',
            openingHours: {
                breakfast: { start: '07:30', end: '10:30' },
                lunch: { start: '12:00', end: '15:30' },
                dinner: { start: '19:00', end: '23:00' }
            },
            rating: {
                average: 4.7,
                count: 200
            },
            isActive: true,
            isVerified: true
        });
        console.log('✅ Created Mess 2:', mess2.name);

        // Create Mess 3: Coastal Kitchen (Non-Veg)
        const mess3 = await Mess.create({
            owner: messOwner._id,
            name: 'Coastal Kitchen',
            description: 'Authentic coastal cuisine with fresh seafood and traditional recipes from Kerala and Goa.',
            address: {
                street: '78, Beach Road',
                area: 'Juhu',
                city: 'Mumbai',
                state: 'Maharashtra',
                pincode: '400049',
                coordinates: {
                    latitude: 19.0990,
                    longitude: 72.8258
                }
            },
            contact: {
                phone: '9876543212',
                email: 'coastal@mess.com',
                whatsapp: '9876543212'
            },
            mealType: 'non-veg',
            openingHours: {
                breakfast: { start: '08:00', end: '11:00' },
                lunch: { start: '12:30', end: '15:00' },
                dinner: { start: '19:30', end: '22:30' }
            },
            rating: {
                average: 4.8,
                count: 150
            },
            isActive: true,
            isVerified: true
        });
        console.log('✅ Created Mess 3:', mess3.name);

        // Create Mess 4: Punjabi Dhaba (Non-Veg)
        const mess4 = await Mess.create({
            owner: messOwner2._id,
            name: 'Punjabi Dhaba',
            description: 'Authentic Punjabi cuisine with rich, flavorful dishes. Famous for butter chicken and sarson ka saag.',
            address: {
                street: '23, SV Road',
                area: 'Borivali West',
                city: 'Mumbai',
                state: 'Maharashtra',
                pincode: '400092',
                coordinates: {
                    latitude: 19.2285,
                    longitude: 72.8540
                }
            },
            contact: {
                phone: '9876543216',
                email: 'punjabidhaba@mess.com',
                whatsapp: '9876543216'
            },
            mealType: 'non-veg',
            openingHours: {
                breakfast: { start: '07:00', end: '11:00' },
                lunch: { start: '12:00', end: '16:00' },
                dinner: { start: '19:00', end: '23:30' }
            },
            rating: {
                average: 4.6,
                count: 180
            },
            isActive: true,
            isVerified: true
        });
        console.log('✅ Created Mess 4:', mess4.name);

        // Create Mess 5: Chinese Wok (Veg)
        const mess5 = await Mess.create({
            owner: messOwner2._id,
            name: 'Chinese Wok',
            description: 'Delicious Indo-Chinese vegetarian dishes. Fresh ingredients and authentic flavors.',
            address: {
                street: '56, Hill Road',
                area: 'Bandra West',
                city: 'Mumbai',
                state: 'Maharashtra',
                pincode: '400050',
                coordinates: {
                    latitude: 19.0596,
                    longitude: 72.8295
                }
            },
            contact: {
                phone: '9876543217',
                email: 'chinesewok@mess.com',
                whatsapp: '9876543217'
            },
            mealType: 'veg',
            openingHours: {
                breakfast: { start: '08:00', end: '11:00' },
                lunch: { start: '12:00', end: '15:00' },
                dinner: { start: '19:00', end: '22:00' }
            },
            rating: {
                average: 4.4,
                count: 95
            },
            isActive: true,
            isVerified: true
        });
        console.log('✅ Created Mess 5:', mess5.name);

        // Create Meal Groups for Mess 1 (Annapurna - Veg)
        const mess1Meals = await MealGroup.insertMany([
            {
                mess: mess1._id,
                name: 'Healthy Breakfast Combo',
                description: 'Start your day right with nutritious breakfast',
                mealType: 'breakfast',
                category: 'veg',
                items: [
                    { name: 'Poha', quantity: '1 plate' },
                    { name: 'Tea/Coffee', quantity: '1 cup' },
                    { name: 'Banana', quantity: '1 piece' }
                ],
                price: 60,
                totalTiffins: 50,
                availableTiffins: 50,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            },
            {
                mess: mess1._id,
                name: 'Deluxe Lunch Thali',
                description: 'Complete meal with variety',
                mealType: 'lunch',
                category: 'veg',
                items: [
                    { name: 'Chapati', quantity: '4 pieces' },
                    { name: 'Dal Tadka', quantity: '1 bowl' },
                    { name: 'Paneer Sabzi', quantity: '1 bowl' },
                    { name: 'Rice', quantity: '1 plate' },
                    { name: 'Salad', quantity: '1 bowl' },
                    { name: 'Sweet', quantity: '1 piece' }
                ],
                price: 120,
                totalTiffins: 100,
                availableTiffins: 100,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            },
            {
                mess: mess1._id,
                name: 'Simple Dinner',
                description: 'Light and healthy dinner',
                mealType: 'dinner',
                category: 'veg',
                items: [
                    { name: 'Chapati', quantity: '3 pieces' },
                    { name: 'Mixed Veg', quantity: '1 bowl' },
                    { name: 'Dal', quantity: '1 bowl' },
                    { name: 'Rice', quantity: '1 plate' }
                ],
                price: 90,
                totalTiffins: 80,
                availableTiffins: 80,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            }
        ]);
        console.log(`✅ Created ${mess1Meals.length} meals for ${mess1.name}`);

        // Create Meal Groups for Mess 2 (Spice Garden - Both)
        const mess2Meals = await MealGroup.insertMany([
            {
                mess: mess2._id,
                name: 'South Indian Breakfast',
                description: 'Crispy dosa and fluffy idli',
                mealType: 'breakfast',
                category: 'veg',
                items: [
                    { name: 'Masala Dosa', quantity: '2 pieces' },
                    { name: 'Sambar', quantity: '1 bowl' },
                    { name: 'Coconut Chutney', quantity: '1 bowl' },
                    { name: 'Filter Coffee', quantity: '1 cup' }
                ],
                price: 80,
                totalTiffins: 60,
                availableTiffins: 60,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            },
            {
                mess: mess2._id,
                name: 'Chicken Biryani Special',
                description: 'Our signature dish - aromatic and flavorful',
                mealType: 'lunch',
                category: 'non-veg',
                items: [
                    { name: 'Chicken Biryani', quantity: '1 full plate' },
                    { name: 'Raita', quantity: '1 bowl' },
                    { name: 'Salan', quantity: '1 bowl' },
                    { name: 'Gulab Jamun', quantity: '2 pieces' }
                ],
                price: 180,
                totalTiffins: 80,
                availableTiffins: 80,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            },
            {
                mess: mess2._id,
                name: 'Veg Thali',
                description: 'Wholesome vegetarian meal',
                mealType: 'lunch',
                category: 'veg',
                items: [
                    { name: 'Roti', quantity: '4 pieces' },
                    { name: 'Dal Fry', quantity: '1 bowl' },
                    { name: 'Aloo Gobi', quantity: '1 bowl' },
                    { name: 'Rice', quantity: '1 plate' },
                    { name: 'Curd', quantity: '1 bowl' }
                ],
                price: 110,
                totalTiffins: 70,
                availableTiffins: 70,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            }
        ]);
        console.log(`✅ Created ${mess2Meals.length} meals for ${mess2.name}`);

        // Create Meal Groups for Mess 3 (Coastal Kitchen - Non-Veg)
        const mess3Meals = await MealGroup.insertMany([
            {
                mess: mess3._id,
                name: 'Goan Fish Curry Meal',
                description: 'Authentic Goan style fish curry',
                mealType: 'lunch',
                category: 'non-veg',
                items: [
                    { name: 'Fish Curry', quantity: '2 pieces' },
                    { name: 'Rice', quantity: '1 full plate' },
                    { name: 'Fish Fry', quantity: '1 piece' },
                    { name: 'Sol Kadhi', quantity: '1 glass' }
                ],
                price: 200,
                totalTiffins: 50,
                availableTiffins: 50,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            },
            {
                mess: mess3._id,
                name: 'Prawn Masala Combo',
                description: 'Spicy and tangy prawn preparation',
                mealType: 'dinner',
                category: 'non-veg',
                items: [
                    { name: 'Prawn Masala', quantity: '1 bowl' },
                    { name: 'Naan', quantity: '3 pieces' },
                    { name: 'Jeera Rice', quantity: '1 plate' },
                    { name: 'Salad', quantity: '1 bowl' }
                ],
                price: 220,
                totalTiffins: 40,
                availableTiffins: 40,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            },
            {
                mess: mess3._id,
                name: 'Chicken Cafreal',
                description: 'Goan style green chicken curry',
                mealType: 'dinner',
                category: 'non-veg',
                items: [
                    { name: 'Chicken Cafreal', quantity: '4 pieces' },
                    { name: 'Pav', quantity: '2 pieces' },
                    { name: 'Rice', quantity: '1 plate' },
                    { name: 'Pickle', quantity: '1 portion' }
                ],
                price: 190,
                totalTiffins: 45,
                availableTiffins: 45,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            }
        ]);
        console.log(`✅ Created ${mess3Meals.length} meals for ${mess3.name}`);

        // Create Meal Groups for Mess 4 (Punjabi Dhaba - Non-Veg)
        const mess4Meals = await MealGroup.insertMany([
            {
                mess: mess4._id,
                name: 'Paratha Breakfast',
                description: 'Flaky butter parathas with curd',
                mealType: 'breakfast',
                category: 'veg',
                items: [
                    { name: 'Aloo Paratha', quantity: '2 pieces' },
                    { name: 'Butter', quantity: '2 cubes' },
                    { name: 'Curd', quantity: '1 bowl' },
                    { name: 'Pickle', quantity: '1 portion' }
                ],
                price: 70,
                totalTiffins: 40,
                availableTiffins: 40,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            },
            {
                mess: mess4._id,
                name: 'Butter Chicken Special',
                description: 'Creamy butter chicken with naan',
                mealType: 'lunch',
                category: 'non-veg',
                items: [
                    { name: 'Butter Chicken', quantity: '1 bowl' },
                    { name: 'Naan', quantity: '4 pieces' },
                    { name: 'Rice', quantity: '1 plate' },
                    { name: 'Salad', quantity: '1 bowl' },
                    { name: 'Raita', quantity: '1 bowl' }
                ],
                price: 250,
                totalTiffins: 60,
                availableTiffins: 60,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            },
            {
                mess: mess4._id,
                name: 'Sarson ka Saag Combo',
                description: 'Traditional Punjabi dish with makki roti',
                mealType: 'dinner',
                category: 'veg',
                items: [
                    { name: 'Sarson ka Saag', quantity: '1 bowl' },
                    { name: 'Makki Roti', quantity: '3 pieces' },
                    { name: 'Butter', quantity: '2 cubes' },
                    { name: 'Jaggery', quantity: '1 piece' }
                ],
                price: 180,
                totalTiffins: 35,
                availableTiffins: 35,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            }
        ]);
        console.log(`✅ Created ${mess4Meals.length} meals for ${mess4.name}`);

        // Create Meal Groups for Mess 5 (Chinese Wok - Veg)
        const mess5Meals = await MealGroup.insertMany([
            {
                mess: mess5._id,
                name: 'Noodle Soup Breakfast',
                description: 'Warm noodle soup to start your day',
                mealType: 'breakfast',
                category: 'veg',
                items: [
                    { name: 'Veg Noodle Soup', quantity: '1 bowl' },
                    { name: 'Spring Roll', quantity: '2 pieces' },
                    { name: 'Green Tea', quantity: '1 cup' }
                ],
                price: 85,
                totalTiffins: 30,
                availableTiffins: 30,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            },
            {
                mess: mess5._id,
                name: 'Chowmein Combo',
                description: 'Spicy vegetable chowmein with manchurian',
                mealType: 'lunch',
                category: 'veg',
                items: [
                    { name: 'Veg Chowmein', quantity: '1 full plate' },
                    { name: 'Gobi Manchurian', quantity: '6 pieces' },
                    { name: 'Chilli Sauce', quantity: '1 sachet' },
                    { name: 'Soft Drink', quantity: '1 can' }
                ],
                price: 140,
                totalTiffins: 50,
                availableTiffins: 50,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            },
            {
                mess: mess5._id,
                name: 'Fried Rice Special',
                description: 'Sizzling fried rice with honey chili potato',
                mealType: 'dinner',
                category: 'veg',
                items: [
                    { name: 'Veg Fried Rice', quantity: '1 full plate' },
                    { name: 'Honey Chili Potato', quantity: '1 plate' },
                    { name: 'Hot & Sour Soup', quantity: '1 bowl' },
                    { name: 'Ice Cream', quantity: '1 scoop' }
                ],
                price: 160,
                totalTiffins: 40,
                availableTiffins: 40,
                validUntil: new Date(Date.now() + 24 * 60 * 60 * 1000),
                isActive: true
            }
        ]);
        console.log(`✅ Created ${mess5Meals.length} meals for ${mess5.name}`);

        console.log('\n🎉 Database seeded successfully!\n');
        console.log('📋 Summary:');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('👥 Users Created:');
        console.log(`   • Admin: ${admin.email} / admin123`);
        console.log(`   • Mess Owner: ${messOwner.email} / owner123`);
        console.log(`   • Mess Owner 2: ${messOwner2.email} / owner123`);
        console.log(`   • Regular User: ${regularUser.email} / user123`);
        console.log(`   • User 2: ${user2.email} / user123`);
        console.log(`   • User 3: ${user3.email} / user123`);
        console.log('\n🏪 Messes Created:');
        console.log(`   • ${mess1.name} (Veg) - ${mess1Meals.length} meals`);
        console.log(`   • ${mess2.name} (Both) - ${mess2Meals.length} meals`);
        console.log(`   • ${mess3.name} (Non-Veg) - ${mess3Meals.length} meals`);
        console.log(`   • ${mess4.name} (Non-Veg) - ${mess4Meals.length} meals`);
        console.log(`   • ${mess5.name} (Veg) - ${mess5Meals.length} meals`);
        console.log('\n👥 Total Users: 6 (1 Admin, 2 Mess Owners, 3 Regular Users)');
        console.log('🏪 Total Messes: 5');
        console.log('🍽️  Total Meal Groups: 15');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

        process.exit(0);
    } catch (error) {
        console.error('❌ Error seeding database:', error);
        process.exit(1);
    }
};

seedDatabase();
