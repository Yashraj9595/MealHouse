# Smart Mess Backend API

A comprehensive backend API for Smart Mess - a Zomato-like platform for mess and tiffin services.

## 🚀 Features

- **User Authentication & Authorization**
  - JWT-based authentication
  - Role-based access control (Admin, Mess Owner, User)
  - Secure password hashing with bcrypt

- **Mess Management**
  - Create and manage mess profiles
  - Location-based search
  - Filter by meal type (Veg/Non-Veg/Both)
  - Rating system

- **Meal Group System**
  - Create multiple meal groups per mess
  - Daily meal updates
  - Real-time tiffin availability tracking
  - Automatic inventory management

- **Order Management**
  - Place orders from multiple messes
  - Real-time tiffin count reduction
  - Order status tracking
  - Order cancellation with tiffin restoration
  - Order statistics for mess owners

- **Security Features**
  - Helmet.js for security headers
  - Rate limiting
  - CORS protection
  - Input validation
  - Error handling

## 📋 Prerequisites

- Node.js (v14 or higher)
- MongoDB (local or Atlas)
- npm or yarn

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Setup**
   
   Copy `.env.example` to `.env` and update the values:
   ```bash
   cp .env.example .env
   ```

   Update the following variables in `.env`:
   ```env
   PORT=5000
   NODE_ENV=development
   MONGODB_URI=your_mongodb_connection_string
   JWT_SECRET=your_secret_key
   JWT_EXPIRE=7d
   FRONTEND_URL=http://localhost:3000
   ```

4. **Start MongoDB**
   
   If using local MongoDB:
   ```bash
   mongod
   ```

5. **Run the server**
   
   Development mode:
   ```bash
   npm run dev
   ```

   Production mode:
   ```bash
   npm start
   ```

## 📚 API Documentation

### Base URL
```
http://localhost:5000/api
```

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "9876543210",
  "password": "password123",
  "role": "user" // or "mess_owner"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

#### Get Current User
```http
GET /api/auth/me
Authorization: Bearer <token>
```

### Mess Endpoints

#### Get All Messes
```http
GET /api/messes?city=Mumbai&mealType=veg&search=Annapurna
```

#### Get Single Mess
```http
GET /api/messes/:id
```

#### Create Mess (Mess Owner only)
```http
POST /api/messes
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Annapurna Mess",
  "description": "Best homemade food",
  "address": {
    "street": "123 Main St",
    "city": "Mumbai",
    "state": "Maharashtra",
    "pincode": "400001"
  },
  "contact": {
    "phone": "9876543210",
    "email": "annapurna@example.com"
  },
  "mealType": "veg"
}
```

### Meal Group Endpoints

#### Get Meal Groups for a Mess
```http
GET /api/messes/:messId/mealgroups?mealType=lunch&category=veg
```

#### Create Meal Group (Mess Owner only)
```http
POST /api/messes/:messId/mealgroups
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Lunch Veg Thali",
  "description": "Delicious vegetarian lunch",
  "mealType": "lunch",
  "category": "veg",
  "items": [
    { "name": "Roti", "quantity": "4 pieces" },
    { "name": "Dal", "quantity": "1 bowl" },
    { "name": "Rice", "quantity": "1 plate" },
    { "name": "Sabji", "quantity": "1 bowl" }
  ],
  "price": 80,
  "totalTiffins": 50
}
```

#### Update Tiffin Availability
```http
PUT /api/mealgroups/:id/availability
Authorization: Bearer <token>
Content-Type: application/json

{
  "totalTiffins": 60,
  "availableTiffins": 45
}
```

### Order Endpoints

#### Create Order
```http
POST /api/orders
Authorization: Bearer <token>
Content-Type: application/json

{
  "messId": "mess_id_here",
  "items": [
    {
      "mealGroupId": "meal_group_id_here",
      "quantity": 2
    }
  ],
  "deliveryTime": "2024-02-14T13:00:00Z",
  "contactPhone": "9876543210",
  "specialInstructions": "Extra spicy"
}
```

#### Get My Orders
```http
GET /api/orders
Authorization: Bearer <token>
```

#### Get Order Statistics (Mess Owner)
```http
GET /api/orders/stats/summary
Authorization: Bearer <token>
```

#### Update Order Status (Mess Owner)
```http
PUT /api/orders/:id/status
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "confirmed" // pending, confirmed, preparing, ready, delivered
}
```

#### Cancel Order
```http
PUT /api/orders/:id/cancel
Authorization: Bearer <token>
Content-Type: application/json

{
  "reason": "Changed my mind"
}
```

## 🗂️ Project Structure

```
backend/
├── config/
│   └── db.js                 # Database connection
├── controllers/
│   ├── authController.js     # Authentication logic
│   ├── messController.js     # Mess management
│   ├── mealGroupController.js # Meal group management
│   └── orderController.js    # Order management
├── middleware/
│   ├── auth.js              # Authentication & authorization
│   ├── error.js             # Error handling
│   └── validate.js          # Input validation
├── models/
│   ├── User.js              # User schema
│   ├── Mess.js              # Mess schema
│   ├── MealGroup.js         # Meal group schema
│   ├── Order.js             # Order schema
│   └── Review.js            # Review schema
├── routes/
│   ├── auth.js              # Auth routes
│   ├── messes.js            # Mess routes
│   ├── mealGroups.js        # Meal group routes
│   └── orders.js            # Order routes
├── utils/
│   └── jwt.js               # JWT utilities
├── .env.example             # Environment variables template
├── .gitignore
├── package.json
├── server.js                # Main server file
└── README.md
```

## 🔐 User Roles

1. **User (Customer)**
   - Browse messes
   - View meal groups
   - Place orders
   - View own orders
   - Cancel orders

2. **Mess Owner**
   - All user permissions
   - Create and manage mess
   - Create and manage meal groups
   - Update tiffin availability
   - View and update order status
   - View order statistics

3. **Admin**
   - All permissions
   - Manage all messes
   - Manage all orders
   - Access all statistics

## 🔄 Key Features Explained

### Automatic Tiffin Management
- When an order is placed, available tiffins are automatically reduced
- When an order is cancelled, tiffins are restored
- Real-time availability checking prevents overbooking

### Meal Group System
- Each mess can have multiple meal groups (e.g., Lunch Veg, Dinner Non-Veg)
- Each meal group contains multiple items
- Daily meal updates with validity period
- Independent pricing and availability

### Order Flow
1. User browses messes and meal groups
2. Selects items and places order
3. System checks tiffin availability
4. Reduces available tiffins
5. Creates order with status "pending"
6. Mess owner updates status (confirmed → preparing → ready → delivered)
7. User can cancel before delivery (tiffins restored)

## 🧪 Testing

You can test the API using:
- Postman
- Thunder Client (VS Code extension)
- cURL
- Any HTTP client

## 🚀 Deployment

### Deploy to Heroku
```bash
heroku create smart-mess-api
heroku config:set NODE_ENV=production
heroku config:set MONGODB_URI=your_mongodb_atlas_uri
heroku config:set JWT_SECRET=your_secret
git push heroku main
```

### Deploy to Railway/Render
1. Connect your GitHub repository
2. Set environment variables
3. Deploy

## 📝 License

MIT

## 👨‍💻 Author

Smart Mess Development Team

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
