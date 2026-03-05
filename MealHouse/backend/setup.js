const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 Setting up MealHouse Backend...\n');

// Check if .env exists, create from example if not
const envPath = path.join(__dirname, '.env');
const envExamplePath = path.join(__dirname, '.env.example');

if (!fs.existsSync(envPath)) {
  console.log('📝 Creating .env file from example...');
  fs.copyFileSync(envExamplePath, envPath);
  console.log('✅ .env file created\n');
} else {
  console.log('✅ .env file already exists\n');
}

try {
  // Install dependencies
  console.log('📦 Installing dependencies...');
  execSync('npm install', { stdio: 'inherit', cwd: __dirname });
  console.log('✅ Dependencies installed\n');

  // Check if MongoDB is running (basic check)
  console.log('🔍 Checking MongoDB connection...');
  try {
    execSync('mongosh --eval "db.runCommand({ping: 1})"', { stdio: 'pipe' });
    console.log('✅ MongoDB is running\n');
  } catch (error) {
    console.log('⚠️  MongoDB might not be running. Please start MongoDB service.\n');
  }

  console.log('🌱 Seeding database with sample data...');
  execSync('npm run seed', { stdio: 'inherit', cwd: __dirname });
  console.log('✅ Database seeded successfully!\n');

  console.log('🎉 Setup completed successfully!\n');
  console.log('📋 Next steps:');
  console.log('1. Make sure MongoDB is running');
  console.log('2. Start the server: npm run dev');
  console.log('3. Test API: http://localhost:5000/api/health');
  console.log('\n📱 Sample login credentials:');
  console.log('User: john@example.com / password123');
  console.log('Owner: raj@example.com / password123');
  console.log('Admin: admin@example.com / admin123');

} catch (error) {
  console.error('❌ Setup failed:', error.message);
  console.log('\n🔧 Manual setup:');
  console.log('1. npm install');
  console.log('2. Make sure MongoDB is running');
  console.log('3. npm run seed');
  console.log('4. npm run dev');
}
