# MealHouse Backend API

Complete backend API for the MealHouse food delivery application.

## 🚀 Features

- **Authentication**: User registration, login, profile management
- **Mess Management**: CRUD operations for messes/food services
- **Meal Groups**: Menu items and meal combinations
- **Order Management**: Order creation, tracking, and status updates
- **Database**: MongoDB with Mongoose ODM
- **Security**: JWT authentication, rate limiting, CORS
- **API Documentation**: RESTful API with consistent response format

## 📋 Prerequisites

- Node.js (v14 or higher)
- MongoDB (v4.4 or higher)
- npm or yarn

## 🛠️ Installation

1. **Clone the repository** (if not already done)
2. **Navigate to backend directory**:
   ```bash
   cd backend
   ```

3. **Install dependencies**:
   ```bash
   npm install
   ```

4. **Set up environment variables**:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` file with your configuration.

5. **Start MongoDB**:
   - Make sure MongoDB is running on your system
   - Default connection: `mongodb://localhost:27017/mealhouse`

## 🗄️ Database Setup

### Option 1: Automatic Seeding
```bash
npm run seed
```
This will create sample users, messes, and meal groups.

### Option 2: Manual Setup
The database will be created automatically when you start the server.

## 🚀 Running the Server

### Development Mode
```bash
npm run dev
```
Server will restart automatically on file changes.

### Production Mode
```bash
npm start
```

## 📡 API Endpoints

### Base URL
- Local: `http://localhost:5000/api`
- Network: `http://10.87.156.74:5000/api`

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - User login
- `GET /auth/me` - Get current user profile
- `PUT /auth/updatedetails` - Update user profile
- `POST /auth/logout` - User logout

### Messes
- `GET /messes` - Get all messes (with pagination, search, filters)
- `GET /messes/:id` - Get mess details by ID
- `GET /messes/my` - Get messes owned by current user
- `POST /messes` - Create new mess
- `PUT /messes/:id` - Update mess
- `DELETE /messes/:id` - Delete mess (soft delete)

### Meal Groups
- `GET /mealgroups` - Get all meal groups
- `GET /mealgroups/featured` - Get featured meal groups
- `GET /mealgroups/:id` - Get meal group by ID
- `POST /mealgroups` - Create new meal group
- `PUT /mealgroups/:id` - Update meal group
- `DELETE /mealgroups/:id` - Delete meal group

### Orders
- `GET /orders` - Get all orders (with filters)
- `GET /orders/:id` - Get order by ID
- `POST /orders` - Create new order
- `PUT /orders/:id` - Update order status
- `PUT /orders/:id/rate` - Rate and review order
- `DELETE /orders/:id` - Cancel order

### Health Check
- `GET /health` - Server health status

## 📱 Sample Data

After running `npm run seed`, you'll have:

### Users
- **Regular User**: john@example.com / password123
- **Mess Owner**: raj@example.com / password123  
- **Admin**: admin@example.com / admin123

### Messes
- 6 sample messes with different cuisines
- South Indian, North Indian, Gujarati, Bengali, Chinese, Continental

### Meal Groups
- Sample meal combinations for each mess
- Lunch, dinner, and snack options

## 🔧 API Response Format

All API responses follow this format:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... },
  "pagination": {  // For list endpoints
    "page": 1,
    "limit": 10,
    "total": 100,
    "pages": 10
  }
}
```

Error responses:
```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error message"
}
```

## 🛡️ Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcryptjs for secure password storage
- **Rate Limiting**: Prevent API abuse
- **CORS**: Cross-origin resource sharing
- **Helmet**: Security headers
- **Input Validation**: Mongoose schema validation

## 📝 Testing the API

### Using curl
```bash
# Health check
curl http://localhost:5000/api/health

# Get all messes
curl http://localhost:5000/api/messes

# Register user
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","phone":"9876543210","password":"password123"}'
```

### Using Postman
1. Import the API endpoints
2. Set base URL: `http://localhost:5000/api`
3. Test authentication flow first
4. Use returned token for protected endpoints

## 🔍 Debugging

### Enable Debug Logs
```bash
DEBUG=* npm run dev
```

### Common Issues
1. **MongoDB Connection**: Ensure MongoDB is running
2. **Port Conflict**: Change PORT in .env if 5000 is in use
3. **CORS Issues**: Add your frontend URL to CORS origins

## 🚀 Deployment

### Environment Variables for Production
```bash
NODE_ENV=production
MONGODB_URI=mongodb://your-production-db-url
JWT_SECRET=your-production-secret
```

### Using PM2
```bash
npm install -g pm2
pm2 start server.js --name mealhouse-api
```

## 📞 Support

For issues and questions:
1. Check the console logs for error messages
2. Verify MongoDB connection
3. Ensure all environment variables are set
4. Check API response format in browser dev tools

## 🔄 Next Steps

- Add file upload for mess/meal images
- Implement push notifications
- Add real-time order tracking
- Integrate payment gateway
- Add analytics and reporting
