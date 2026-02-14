# Smart Mess API - Postman Collection Examples

## 1. Authentication

### Register User
```json
POST http://localhost:5000/api/auth/register
Content-Type: application/json

{
  "name": "John Customer",
  "email": "john@example.com",
  "phone": "9876543210",
  "password": "password123",
  "role": "user",
  "address": {
    "street": "123 Main St",
    "city": "Mumbai",
    "state": "Maharashtra",
    "pincode": "400001"
  }
}
```

### Register Mess Owner
```json
POST http://localhost:5000/api/auth/register
Content-Type: application/json

{
  "name": "Ramesh Mess Owner",
  "email": "ramesh@example.com",
  "phone": "9876543211",
  "password": "password123",
  "role": "mess_owner",
  "address": {
    "street": "456 Food St",
    "city": "Mumbai",
    "state": "Maharashtra",
    "pincode": "400002"
  }
}
```

### Login
```json
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "ramesh@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "...",
    "name": "Ramesh Mess Owner",
    "email": "ramesh@example.com",
    "role": "mess_owner"
  }
}
```

## 2. Mess Management

### Create Mess (Mess Owner)
```json
POST http://localhost:5000/api/messes
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "name": "Annapurna Mess",
  "description": "Authentic homemade vegetarian food",
  "address": {
    "street": "15 MG Road",
    "area": "Andheri West",
    "city": "Mumbai",
    "state": "Maharashtra",
    "pincode": "400058",
    "coordinates": {
      "latitude": 19.1334,
      "longitude": 72.8291
    }
  },
  "contact": {
    "phone": "9876543210",
    "email": "annapurna@example.com",
    "whatsapp": "9876543210"
  },
  "mealType": "veg",
  "openingHours": {
    "breakfast": {
      "start": "07:00",
      "end": "10:00"
    },
    "lunch": {
      "start": "12:00",
      "end": "15:00"
    },
    "dinner": {
      "start": "19:00",
      "end": "22:00"
    }
  }
}
```

### Get All Messes
```
GET http://localhost:5000/api/messes
```

### Get Messes with Filters
```
GET http://localhost:5000/api/messes?city=Mumbai&mealType=veg&search=Annapurna
```

### Get My Mess (Mess Owner)
```
GET http://localhost:5000/api/messes/my/mess
Authorization: Bearer YOUR_TOKEN_HERE
```

## 3. Meal Group Management

### Create Meal Group (Mess Owner)
```json
POST http://localhost:5000/api/messes/MESS_ID_HERE/mealgroups
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "name": "Lunch Veg Thali",
  "description": "Complete vegetarian lunch with variety",
  "mealType": "lunch",
  "category": "veg",
  "items": [
    {
      "name": "Chapati",
      "quantity": "4 pieces",
      "description": "Soft wheat chapatis"
    },
    {
      "name": "Dal Tadka",
      "quantity": "1 bowl",
      "description": "Yellow lentils with tempering"
    },
    {
      "name": "Jeera Rice",
      "quantity": "1 plate",
      "description": "Cumin flavored rice"
    },
    {
      "name": "Mix Veg Sabji",
      "quantity": "1 bowl",
      "description": "Seasonal vegetables"
    },
    {
      "name": "Curd",
      "quantity": "1 bowl",
      "description": "Fresh yogurt"
    },
    {
      "name": "Salad",
      "quantity": "1 plate",
      "description": "Fresh green salad"
    }
  ],
  "price": 80,
  "totalTiffins": 50,
  "validUntil": "2024-02-14T23:59:59Z"
}
```

### Create Dinner Meal Group
```json
POST http://localhost:5000/api/messes/MESS_ID_HERE/mealgroups
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "name": "Dinner Special Thali",
  "description": "Delicious dinner combo",
  "mealType": "dinner",
  "category": "veg",
  "items": [
    {
      "name": "Roti",
      "quantity": "5 pieces"
    },
    {
      "name": "Paneer Butter Masala",
      "quantity": "1 bowl"
    },
    {
      "name": "Dal Makhani",
      "quantity": "1 bowl"
    },
    {
      "name": "Pulao",
      "quantity": "1 plate"
    },
    {
      "name": "Raita",
      "quantity": "1 bowl"
    },
    {
      "name": "Sweet",
      "quantity": "1 piece"
    }
  ],
  "price": 120,
  "totalTiffins": 40
}
```

### Get Meal Groups for a Mess
```
GET http://localhost:5000/api/messes/MESS_ID_HERE/mealgroups
```

### Update Tiffin Availability
```json
PUT http://localhost:5000/api/mealgroups/MEAL_GROUP_ID/availability
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "totalTiffins": 60,
  "availableTiffins": 45
}
```

## 4. Order Management

### Create Order (User)
```json
POST http://localhost:5000/api/orders
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "messId": "MESS_ID_HERE",
  "items": [
    {
      "mealGroupId": "MEAL_GROUP_ID_1",
      "quantity": 2
    },
    {
      "mealGroupId": "MEAL_GROUP_ID_2",
      "quantity": 1
    }
  ],
  "deliveryAddress": {
    "street": "123 Main St",
    "area": "Andheri",
    "city": "Mumbai",
    "state": "Maharashtra",
    "pincode": "400058"
  },
  "contactPhone": "9876543210",
  "deliveryTime": "2024-02-14T13:00:00Z",
  "specialInstructions": "Please make it less spicy"
}
```

### Get My Orders (User)
```
GET http://localhost:5000/api/orders
Authorization: Bearer YOUR_TOKEN_HERE
```

### Get Orders with Filters
```
GET http://localhost:5000/api/orders?status=pending&startDate=2024-02-01&endDate=2024-02-14
Authorization: Bearer YOUR_TOKEN_HERE
```

### Get Single Order
```
GET http://localhost:5000/api/orders/ORDER_ID
Authorization: Bearer YOUR_TOKEN_HERE
```

### Update Order Status (Mess Owner)
```json
PUT http://localhost:5000/api/orders/ORDER_ID/status
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "status": "confirmed"
}
```

**Status Flow:**
- pending → confirmed → preparing → ready → delivered

### Cancel Order (User)
```json
PUT http://localhost:5000/api/orders/ORDER_ID/cancel
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "reason": "Changed my plans"
}
```

### Get Order Statistics (Mess Owner)
```
GET http://localhost:5000/api/orders/stats/summary
Authorization: Bearer YOUR_TOKEN_HERE
```

## 5. User Profile Management

### Get Current User
```
GET http://localhost:5000/api/auth/me
Authorization: Bearer YOUR_TOKEN_HERE
```

### Update Profile
```json
PUT http://localhost:5000/api/auth/updatedetails
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "name": "John Updated",
  "phone": "9876543299",
  "address": {
    "street": "New Street 123",
    "city": "Mumbai",
    "state": "Maharashtra",
    "pincode": "400001"
  }
}
```

### Update Password
```json
PUT http://localhost:5000/api/auth/updatepassword
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "currentPassword": "password123",
  "newPassword": "newpassword456"
}
```

## Testing Workflow

### Step 1: Setup
1. Start MongoDB
2. Start the server: `npm run dev`

### Step 2: Create Users
1. Register a mess owner
2. Register a customer
3. Login and save tokens

### Step 3: Create Mess & Meals
1. Login as mess owner
2. Create a mess
3. Create multiple meal groups (breakfast, lunch, dinner)

### Step 4: Place Orders
1. Login as customer
2. Browse messes
3. View meal groups
4. Place an order

### Step 5: Manage Orders
1. Login as mess owner
2. View orders
3. Update order status
4. View statistics

### Step 6: Test Cancellation
1. Login as customer
2. Cancel an order
3. Verify tiffins are restored

## Common Response Formats

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message here",
  "errors": [ ... ]
}
```

### Validation Error
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Please provide a valid email"
    }
  ]
}
```
