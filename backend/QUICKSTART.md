# Smart Mess Backend - Quick Start Guide

## Prerequisites Checklist

- [ ] Node.js installed (v14+)
- [ ] MongoDB installed and running
- [ ] Code editor (VS Code recommended)
- [ ] API testing tool (Postman/Thunder Client)

## Quick Setup (5 minutes)

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment
The `.env` file is already created with default settings:
- MongoDB: `mongodb://localhost:27017/smart_mess`
- Port: `5000`
- JWT Secret: Pre-configured (change in production!)

### 3. Start MongoDB
**Windows:**
```bash
# Open new terminal
mongod
```

**Mac/Linux:**
```bash
sudo systemctl start mongod
# or
brew services start mongodb-community
```

### 4. Start Server
```bash
npm run dev
```

You should see:
```
╔════════════════════════════════════════════════════════╗
║                                                        ║
║           🍽️  SMART MESS API SERVER 🍽️                ║
║                                                        ║
║  Server running in development mode                   ║
║  Port: 5000                                           ║
║  URL: http://localhost:5000                           ║
║                                                        ║
╚════════════════════════════════════════════════════════╝

MongoDB Connected: localhost
```

### 5. Test the API
Open browser or Postman:
```
http://localhost:5000/health
```

Should return:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2024-02-14T..."
}
```

## Quick Test Flow

### 1. Register Mess Owner
```bash
POST http://localhost:5000/api/auth/register
Content-Type: application/json

{
  "name": "Test Owner",
  "email": "owner@test.com",
  "phone": "9876543210",
  "password": "test123",
  "role": "mess_owner"
}
```

### 2. Login
```bash
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "owner@test.com",
  "password": "test123"
}
```

**Copy the token from response!**

### 3. Create Mess
```bash
POST http://localhost:5000/api/messes
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "name": "Test Mess",
  "address": {
    "street": "123 Test St",
    "city": "Mumbai",
    "state": "Maharashtra",
    "pincode": "400001"
  },
  "contact": {
    "phone": "9876543210"
  },
  "mealType": "veg"
}
```

### 4. Create Meal Group
```bash
POST http://localhost:5000/api/messes/MESS_ID/mealgroups
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "name": "Lunch Thali",
  "mealType": "lunch",
  "category": "veg",
  "items": [
    {"name": "Roti", "quantity": "4"},
    {"name": "Dal", "quantity": "1 bowl"}
  ],
  "price": 80,
  "totalTiffins": 50
}
```

### 5. Register Customer & Place Order
```bash
# Register
POST http://localhost:5000/api/auth/register
{
  "name": "Customer",
  "email": "customer@test.com",
  "phone": "9876543211",
  "password": "test123",
  "role": "user"
}

# Login and get token
POST http://localhost:5000/api/auth/login
{
  "email": "customer@test.com",
  "password": "test123"
}

# Place Order
POST http://localhost:5000/api/orders
Authorization: Bearer CUSTOMER_TOKEN
{
  "messId": "MESS_ID",
  "items": [
    {
      "mealGroupId": "MEAL_GROUP_ID",
      "quantity": 2
    }
  ],
  "deliveryTime": "2024-02-14T13:00:00Z",
  "contactPhone": "9876543211"
}
```

## Common Issues & Solutions

### MongoDB Connection Error
**Error:** `MongooseServerSelectionError`

**Solution:**
1. Make sure MongoDB is running: `mongod`
2. Check if port 27017 is available
3. Verify MONGODB_URI in `.env`

### Port Already in Use
**Error:** `EADDRINUSE: address already in use :::5000`

**Solution:**
1. Change PORT in `.env` to 5001
2. Or kill process on port 5000:
   ```bash
   # Windows
   netstat -ano | findstr :5000
   taskkill /PID <PID> /F
   
   # Mac/Linux
   lsof -ti:5000 | xargs kill -9
   ```

### JWT Token Invalid
**Error:** `Not authorized to access this route`

**Solution:**
1. Make sure you're including the token in headers
2. Format: `Authorization: Bearer YOUR_TOKEN`
3. Token might be expired - login again

### Validation Errors
**Error:** `Validation failed`

**Solution:**
Check the error response for specific field errors and fix the request body.

## Project Structure Overview

```
backend/
├── models/          # Database schemas
│   ├── User.js      # User authentication
│   ├── Mess.js      # Mess profiles
│   ├── MealGroup.js # Meal groups & tiffins
│   └── Order.js     # Order management
├── controllers/     # Business logic
├── routes/          # API endpoints
├── middleware/      # Auth, validation, errors
├── config/          # Database connection
└── server.js        # Main entry point
```

## Next Steps

1. ✅ Backend is running
2. 📱 Build mobile app (React Native)
3. 🌐 Build web frontend (React/Next.js)
4. 🚀 Deploy to production

## Need Help?

- Check `README.md` for full documentation
- See `API_TESTING.md` for all API endpoints
- Review code comments in each file

## Production Deployment Checklist

Before deploying to production:

- [ ] Change JWT_SECRET in `.env`
- [ ] Use MongoDB Atlas (cloud database)
- [ ] Set NODE_ENV=production
- [ ] Enable HTTPS
- [ ] Configure proper CORS
- [ ] Set up proper logging
- [ ] Add rate limiting (already included)
- [ ] Set up monitoring
- [ ] Configure backup strategy

Happy Coding! 🚀
