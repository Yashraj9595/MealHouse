import { Request } from 'express';

export interface IUser {
  _id?: string;
  email: string;
  firstName: string;
  lastName: string;
  mobile: string;
  profileImage?: string;
  savedLocations?: ISavedLocation[];
  pickupPreferences?: IPickupPreferences;
  role: UserRole;
  password: string;
  isEmailVerified: boolean;
  isMobileVerified: boolean;
  isActive: boolean;
  lastLogin?: Date;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface ISavedLocation {
  label: string;
  address: string;
  latitude?: number;
  longitude?: number;
  icon?: string;
}

export interface IPickupPreferences {
  breakfast?: string;
  lunch?: string;
  dinner?: string;
}

export type UserRole = 'admin' | 'manager' | 'user' | 'mess_owner';

export interface IOTP {
  _id?: string;
  email: string;
  mobile?: string;
  otp: string;
  type: OTPType;
  expiresAt: Date;
  isUsed: boolean;
  attempts: number;
  createdAt?: Date;
}

export type OTPType = 'email_verification' | 'password_reset' | 'mobile_verification' | 'login';

export interface IAuthRequest extends Request {
  user?: IUser;
  file?: any;
}

export interface ILoginData {
  email: string;
  password: string;
  rememberMe?: boolean;
}

export interface IRegisterData {
  email: string;
  password: string;
  confirmPassword: string;
  firstName: string;
  lastName: string;
  mobile: string;
  role: UserRole;
  acceptedTerms: boolean;
}

export interface IForgotPasswordData {
  email: string;
}

export interface IOTPVerificationData {
  email: string;
  otp: string;
  type?: OTPType;
}

export interface IResetPasswordData {
  email: string;
  otp: string;
  newPassword: string;
  confirmPassword: string;
}

export interface IChangePasswordData {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}

export interface IUpdateProfileData {
  firstName?: string;
  lastName?: string;
  mobile?: string;
  profileImage?: string;
  savedLocations?: ISavedLocation[];
  pickupPreferences?: IPickupPreferences;
}

export interface IAuthResponse {
  success: boolean;
  message: string;
  data?: {
    user: Partial<IUser>;
    token: string;
    refreshToken?: string;
  };
}

export interface IOTPResponse {
  success: boolean;
  message: string;
  data?: {
    email: string;
    expiresAt: Date;
  };
}

export interface IApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  error?: string;
}

export interface IPaginationQuery {
  page?: number;
  limit?: number;
  sort?: string;
  order?: 'asc' | 'desc';
}

export interface IPaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

export interface IUserQuery extends IPaginationQuery {
  role?: UserRole;
  isActive?: boolean;
  search?: string;
}

export interface IEmailOptions {
  to: string;
  subject: string;
  html: string;
  text?: string;
}

export interface IOTPEmailData {
  otp: string;
  expiresIn: string;
  type: string;
}

export interface IRateLimitConfig {
  windowMs: number;
  max: number;
  message: string;
  standardHeaders: boolean;
  legacyHeaders: boolean;
}

export interface IError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

export interface IOperatingHours {
  day: string;
  isOpen: boolean;
  breakfast?: { start: string; end: string };
  lunch?: { start: string; end: string };
  dinner?: { start: string; end: string };
}

export interface IMess {
  _id: string;
  name: string;
  ownerName: string;
  ownerId: any; // Reference to IUser
  mobile: string;
  description: string;
  cuisineType: string;
  address: string;
  location: {
    type: 'Point';
    coordinates: number[]; // [longitude, latitude]
  };
  photos: string[];
  logo?: string;
  rating: number;
  numReviews: number;
  isApproved: boolean;
  isActive: boolean;
  operatingHours?: IOperatingHours[];
  createdAt?: Date;
  updatedAt?: Date;
}

export interface IMenu {
  _id?: string;
  messId: string;
  items: IMenuItem[];
  updatedAt?: Date;
}

export interface IMenuItem {
  name: string;
  description?: string;
  price: number;
  category: string;
  mealType: string[]; // ['Breakfast', 'Lunch', 'Dinner', 'Extra']
  isAvailable: boolean;
  image?: string;
  ingredients?: string[];
  platesAvailable?: number;
}

export interface IOrder {
  _id?: string;
  userId: string;
  messId: string;
  items: IOrderItem[];
  totalPrice: number;
  status: OrderStatus;
  paymentStatus: 'Pending' | 'Completed' | 'Failed';
  paymentMethod: string;
  orderDate: Date;
  razorpayOrderId?: string;
  razorpayPaymentId?: string;
  razorpaySignature?: string;
}

export interface IOrderItem {
  name: string;
  quantity: number;
  price: number;
  mealType?: 'Breakfast' | 'Lunch' | 'Dinner' | 'Extra';
}

export type OrderStatus = 'Pending' | 'Confirmed' | 'Preparing' | 'Ready' | 'OutForDelivery' | 'Delivered' | 'Cancelled';
