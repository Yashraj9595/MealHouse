import mongoose, { Document, Schema, Model } from 'mongoose';
import crypto from 'crypto';
import { IOTP, OTPType } from '../types';

export interface IOTPDocument extends Omit<IOTP, '_id'>, Document {
  isExpired(): boolean;
  incrementAttempts(): Promise<void>;
  markAsUsed(): Promise<void>;
}

export interface IOTPModel extends Model<IOTPDocument> {
  generateOTP(length?: number): string;
  createOTP(email: string, type: OTPType, mobile?: string, expiresInMinutes?: number): Promise<IOTPDocument>;
  verifyOTP(email: string, otp: string, type: OTPType): Promise<IOTPDocument | null>;
  cleanExpiredOTPs(): Promise<void>;
}

const otpSchema = new Schema<IOTPDocument>({
  email: {
    type: String,
    required: [true, 'Email is required'],
    lowercase: true,
    trim: true
  },
  mobile: {
    type: String,
    trim: true
  },
  otp: {
    type: String,
    required: [true, 'OTP is required'],
    length: 6
  },
  type: {
    type: String,
    enum: ['email_verification', 'password_reset', 'mobile_verification', 'login'],
    required: [true, 'OTP type is required']
  },
  expiresAt: {
    type: Date,
    required: [true, 'Expiration date is required'],
    default: () => new Date(Date.now() + 10 * 60 * 1000) // 10 minutes from now
  },
  isUsed: {
    type: Boolean,
    default: false
  },
  attempts: {
    type: Number,
    default: 0,
    max: 5
  }
}, {
  timestamps: true
});

// Indexes
otpSchema.index({ email: 1, type: 1 });
otpSchema.index({ mobile: 1, type: 1 });
otpSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL index

// Instance method to check if OTP is expired
otpSchema.methods.isExpired = function(): boolean {
  return new Date() > this.expiresAt;
};

// Instance method to increment attempts
otpSchema.methods.incrementAttempts = async function(): Promise<void> {
  this.attempts += 1;
  await this.save();
};

// Instance method to mark OTP as used
otpSchema.methods.markAsUsed = async function(): Promise<void> {
  this.isUsed = true;
  await this.save();
};

// Static method to generate OTP
otpSchema.statics.generateOTP = function(length: number = 6): string {
  return crypto.randomInt(100000, 999999).toString().padStart(length, '0');
};

// Static method to create OTP
otpSchema.statics.createOTP = async function(
  email: string,
  type: OTPType,
  mobile?: string,
  expiresInMinutes: number = 10
): Promise<IOTPDocument> {
  // Remove any existing OTPs for this email and type
  await this.deleteMany({ email, type });
  
  const otp = crypto.randomInt(100000, 999999).toString().padStart(6, '0');
  const expiresAt = new Date(Date.now() + expiresInMinutes * 60 * 1000);
  
  return this.create({
    email,
    mobile,
    otp,
    type,
    expiresAt
  });
};

// Static method to verify OTP
otpSchema.statics.verifyOTP = async function(
  email: string,
  otp: string,
  type: OTPType
): Promise<IOTPDocument | null> {
  const otpRecord = await this.findOne({
    email,
    otp,
    type,
    isUsed: false,
    expiresAt: { $gt: new Date() }
  });

  if (!otpRecord) {
    return null;
  }

  // Check attempts limit
  if (otpRecord.attempts >= 5) {
    throw new Error('Maximum attempts exceeded. Please request a new OTP.');
  }

  return otpRecord;
};

// Static method to clean expired OTPs
otpSchema.statics.cleanExpiredOTPs = async function(): Promise<void> {
  await this.deleteMany({
    $or: [
      { expiresAt: { $lt: new Date() } },
      { isUsed: true }
    ]
  });
};

export const OTP = mongoose.model<IOTPDocument, IOTPModel>('OTP', otpSchema) as IOTPModel;
