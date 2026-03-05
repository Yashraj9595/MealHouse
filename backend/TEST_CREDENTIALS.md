# Test Credentials & Database Info

## 🔐 User Accounts

### Admin Account
- **Email:** admin@messapp.com
- **Password:** admin123
- **Role:** admin
- **Phone:** 9999999999

### Mess Owner Account
- **Email:** rajesh@messowner.com
- **Password:** owner123
- **Role:** mess_owner
- **Phone:** 9876543210
- **Owns:** All 3 messes

### Regular User Account
- **Email:** priya@user.com
- **Password:** user123
- **Role:** user
- **Phone:** 9876543211

---

## 🏪 Messes Created

### 1. Annapurna Mess (Vegetarian)
- **Location:** Andheri West, Mumbai
- **Type:** Pure Veg
- **Rating:** 4.5 ⭐ (120 reviews)
- **Meals:** 3 (Breakfast, Lunch, Dinner)
- **Price Range:** ₹60 - ₹120

### 2. Spice Garden (Both Veg & Non-Veg)
- **Location:** Bandra East, Mumbai
- **Type:** Veg & Non-Veg
- **Rating:** 4.7 ⭐ (200 reviews)
- **Meals:** 3 (South Indian Breakfast, Chicken Biryani, Veg Thali)
- **Price Range:** ₹80 - ₹180

### 3. Coastal Kitchen (Non-Vegetarian)
- **Location:** Juhu, Mumbai
- **Type:** Non-Veg (Seafood Specialty)
- **Rating:** 4.8 ⭐ (150 reviews)
- **Meals:** 3 (Fish Curry, Prawn Masala, Chicken Cafreal)
- **Price Range:** ₹190 - ₹220

---

## 🍽️ Sample Meals

### Annapurna Mess
1. **Healthy Breakfast Combo** - ₹60 (Poha, Tea/Coffee, Banana)
2. **Deluxe Lunch Thali** - ₹120 (Chapati, Dal, Paneer, Rice, Salad, Sweet)
3. **Simple Dinner** - ₹90 (Chapati, Mixed Veg, Dal, Rice)

### Spice Garden
1. **South Indian Breakfast** - ₹80 (Masala Dosa, Sambar, Chutney, Coffee)
2. **Chicken Biryani Special** - ₹180 (Biryani, Raita, Salan, Gulab Jamun)
3. **Veg Thali** - ₹110 (Roti, Dal Fry, Aloo Gobi, Rice, Curd)

### Coastal Kitchen
1. **Goan Fish Curry Meal** - ₹200 (Fish Curry, Rice, Fish Fry, Sol Kadhi)
2. **Prawn Masala Combo** - ₹220 (Prawn Masala, Naan, Jeera Rice, Salad)
3. **Chicken Cafreal** - ₹190 (Chicken Cafreal, Pav, Rice, Pickle)

---

## 🧪 Testing Instructions

### Test Login (Flutter App)
1. Open the app
2. Go to Login screen
3. Use any of the credentials above
4. Should successfully login and receive JWT token

### Test Meal Fetching
1. Login as mess owner: `rajesh@messowner.com` / `owner123`
2. Navigate to meal management
3. Should see all 9 meals across 3 messes

### Test Meal Creation
1. Login as mess owner
2. Go to "Add Meal" screen
3. Create a new meal
4. Should save to database and appear in list

---

## 🔄 Re-seed Database
To reset and re-populate the database:
```bash
cd "d:/R mess/backend"
node seed.js
```

---

## 📡 API Endpoints to Test

### Auth
- POST `/api/auth/login` - Login with credentials above
- POST `/api/auth/register` - Create new user
- GET `/api/auth/me` - Get current user (requires token)

### Messes
- GET `/api/messes` - Get all messes
- GET `/api/messes/:id` - Get specific mess

### Meals
- GET `/api/messes/:messId/mealgroups` - Get meals for a mess
- POST `/api/messes/:messId/mealgroups` - Create meal (mess owner only)
