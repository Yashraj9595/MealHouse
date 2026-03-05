# 🚀 Complete Backend Setup Guide for MealHouse

## ✅ What's Already Done:
- ✅ Backend API created with all routes
- ✅ Database models (Users, Messes, MealGroups, Orders)
- ✅ Authentication system with JWT
- ✅ Sample data seeding script
- ✅ Dependencies installed
- ✅ Environment configuration ready

## 🔧 Step 1: Install and Start MongoDB

### Option A: Install MongoDB locally
1. **Download MongoDB Community Server**: https://www.mongodb.com/try/download/community
2. **Install MongoDB** (Windows):
   - Run the installer
   - Choose "Complete" installation
   - Install MongoDB Compass (optional GUI)
3. **Start MongoDB Service**:
   ```bash
   # Open PowerShell as Administrator
   net start MongoDB
   ```

### Option B: Use MongoDB Atlas (Cloud)
1. **Sign up**: https://www.mongodb.com/cloud/atlas
2. **Create free cluster**
3. **Get connection string**
4. **Update .env file**:
   ```
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/mealhouse
   ```

### Option C: Use Docker
```bash
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

## 🔧 Step 2: Start MongoDB Service

### Windows:
```powershell
# Check if MongoDB is running
Get-Service MongoDB

# Start MongoDB service
Start-Service MongoDB

# Or restart if already running
Restart-Service MongoDB
```

### Verify MongoDB is running:
```bash
# Open MongoDB Shell
mongosh

# Or check with command
mongosh --eval "db.runCommand({ping: 1})"
```

## 🔧 Step 3: Seed the Database

Once MongoDB is running:

```bash
cd backend
npm run seed
```

You should see:
```
🌱 Starting database seeding...
🗑️  Cleared existing data
👥 Created 4 users
🏪 Created 6 messes
🍱 Created 3 meal groups
✅ Database seeding completed successfully!
```

## 🔧 Step 4: Start the Backend Server

```bash
npm run dev
```

You should see:
```
🚀 MealHouse API server running on port 5000
📱 Local: http://localhost:5000
📱 Network: http://10.87.156.74:5000
🔗 Health check: http://10.87.156.74:5000/api/health
✅ Connected to MongoDB
```

## 📱 Step 5: Test the API

### Health Check:
```bash
curl http://localhost:5000/api/health
```

### Get All Messes:
```bash
curl http://localhost:5000/api/messes
```

### Test in Browser:
Open these URLs in your browser:
- http://localhost:5000/api/health
- http://localhost:5000/api/messes
- http://10.87.156.74:5000/api/messes

## 🔑 Sample Login Credentials:

After seeding, you can use these credentials:

### Regular User:
- **Email**: john@example.com
- **Password**: password123

### Mess Owner:
- **Email**: raj@example.com  
- **Password**: password123

### Admin:
- **Email**: admin@example.com
- **Password**: admin123

## 📱 Step 6: Connect Flutter App

Your Flutter app is already configured to connect to:
`http://10.87.156.74:5000/api`

1. **Start backend server**: `npm run dev`
2. **Connect phone via USB**
3. **Run Flutter app**: `flutter run`
4. **Check console logs** for API calls

## 🔍 Troubleshooting:

### MongoDB Connection Issues:
```bash
# Check MongoDB status
Get-Service MongoDB

# Start MongoDB manually
mongod --dbpath "C:\data\db"

# Check if port 27017 is available
netstat -an | findstr 27017
```

### Port Already in Use:
```bash
# Check what's using port 5000
netstat -ano | findstr 5000

# Kill the process
taskkill /PID <PROCESS_ID> /F
```

### Firewall Issues:
1. Open Windows Defender Firewall
2. Add port 5000 to inbound rules
3. Allow Node.js through firewall

### Database Not Seeding:
```bash
# Clear MongoDB and reseed
mongosh
use mealhouse
db.dropDatabase()
exit

npm run seed
```

## 🎯 Expected Results:

### ✅ Working Setup:
- Backend server running on port 5000
- MongoDB connected with sample data
- API endpoints responding correctly
- Flutter app loading real data

### ❌ Common Issues:
- MongoDB not running → Start MongoDB service
- Port conflicts → Change PORT in .env
- Firewall blocking → Add firewall exceptions
- Network issues → Check IP address in Flutter config

## 📞 Quick Commands:

```bash
# Start everything (MongoDB must be running first)
cd backend
npm run dev

# Seed database (one time setup)
npm run seed

# Check server status
curl http://localhost:5000/api/health

# View database contents
mongosh
use mealhouse
db.users.find()
db.messes.find()
db.mealgroups.find()
```

## 🔄 Next Steps:

1. ✅ Install and start MongoDB
2. ✅ Seed database with sample data  
3. ✅ Start backend server
4. ✅ Test API endpoints
5. ✅ Connect Flutter app
6. ✅ Verify data loading in app

Once completed, your MealHouse app will have a fully functional backend with real data!
