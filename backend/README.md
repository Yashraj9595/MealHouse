# Auth Backend API

A comprehensive Node.js Express TypeScript backend with MongoDB, JWT authentication, OTP functionality, and role-based access control.

## Features

- 🔐 **JWT Authentication** with access and refresh tokens
- 👥 **Role-based Access Control** (Admin, Manager, User)
- 📧 **OTP System** with email verification and password reset
- 🛡️ **Security** with rate limiting, CORS, and data sanitization
- 📊 **User Management** with admin dashboard functionality
- 🔄 **Password Reset** with OTP verification
- 📱 **Mobile-friendly** API design
- 🚀 **TypeScript** for type safety
- 🗄️ **MongoDB** with Mongoose ODM

## Tech Stack

- **Node.js** with Express.js
- **TypeScript** for type safety
- **MongoDB** with Mongoose ODM
- **JWT** for authentication
- **Nodemailer** for email services
- **Bcryptjs** for password hashing
- **Express Validator** for input validation
- **Helmet** for security headers
- **CORS** for cross-origin requests
- **Rate Limiting** for API protection

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Setup**
   ```bash
   cp env.example .env
   ```
   
   Update the `.env` file with your configuration:
   ```env
   NODE_ENV=development
   PORT=5000
   MONGODB_URI=mongodb://localhost:27017/auth-app
   JWT_SECRET=your-super-secret-jwt-key
   EMAIL_USER=your-email@gmail.com
   EMAIL_PASS=your-app-password
   ```

4. **Start the development server**
   ```bash
   npm run dev
   ```

## API Endpoints

### Authentication Routes (`/api/v1/auth`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/register` | Register new user | No |
| POST | `/login` | User login | No |
| POST | `/forgot-password` | Send OTP for password reset | No |
| POST | `/verify-otp` | Verify OTP | No |
| POST | `/reset-password` | Reset password with OTP | No |
| POST | `/refresh-token` | Refresh access token | No |
| GET | `/profile` | Get user profile | Yes |
| PUT | `/profile` | Update user profile | Yes |
| PUT | `/change-password` | Change password | Yes |
| POST | `/logout` | User logout | Yes |

### User Management Routes (`/api/v1/users`)

| Method | Endpoint | Description | Auth Required | Role Required |
|--------|----------|-------------|---------------|---------------|
| GET | `/` | Get all users | Yes | Admin |
| GET | `/stats` | Get user statistics | Yes | Admin |
| GET | `/search` | Search users | Yes | Admin |
| GET | `/:id` | Get user by ID | Yes | Admin |
| PUT | `/:id` | Update user | Yes | Admin |
| DELETE | `/:id` | Delete user | Yes | Admin |
| PATCH | `/:id/deactivate` | Deactivate user | Yes | Admin |
| PATCH | `/:id/activate` | Activate user | Yes | Admin |

## Request/Response Examples

### Register User
```bash
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "confirmPassword": "password123",
  "firstName": "John",
  "lastName": "Doe",
  "mobile": "+1234567890",
  "role": "user",
  "acceptedTerms": true
}
```

### Login User
```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "rememberMe": true
}
```

### Forgot Password
```bash
POST /api/v1/auth/forgot-password
Content-Type: application/json

{
  "email": "user@example.com"
}
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment | development |
| `PORT` | Server port | 5000 |
| `MONGODB_URI` | MongoDB connection string | mongodb://localhost:27017/auth-app |
| `JWT_SECRET` | JWT secret key | - |
| `JWT_EXPIRE` | JWT expiration time | 7d |
| `EMAIL_HOST` | SMTP host | smtp.gmail.com |
| `EMAIL_USER` | SMTP username | - |
| `EMAIL_PASS` | SMTP password | - |
| `CORS_ORIGIN` | CORS origin | http://localhost:3000 |

## Scripts

```bash
# Development
npm run dev          # Start development server with nodemon

# Production
npm run build        # Build TypeScript to JavaScript
npm start           # Start production server

# Code Quality
npm run lint        # Run ESLint
npm run lint:fix    # Fix ESLint errors
```

## Database Models

### User Model
```typescript
{
  email: string;
  firstName: string;
  lastName: string;
  mobile: string;
  role: 'admin' | 'manager' | 'user';
  password: string;
  isEmailVerified: boolean;
  isMobileVerified: boolean;
  isActive: boolean;
  lastLogin?: Date;
  createdAt: Date;
  updatedAt: Date;
}
```

### OTP Model
```typescript
{
  email: string;
  mobile?: string;
  otp: string;
  type: 'email_verification' | 'password_reset' | 'mobile_verification' | 'login';
  expiresAt: Date;
  isUsed: boolean;
  attempts: number;
  createdAt: Date;
}
```

## Security Features

- **Rate Limiting**: Prevents API abuse
- **CORS**: Configurable cross-origin requests
- **Helmet**: Security headers
- **Data Sanitization**: Prevents NoSQL injection
- **Password Hashing**: Bcrypt with salt rounds
- **JWT Security**: Secure token handling
- **Input Validation**: Comprehensive request validation

## Error Handling

The API returns consistent error responses:

```json
{
  "success": false,
  "message": "Error description",
  "errors": ["Detailed error messages"]
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License - see LICENSE file for details.
