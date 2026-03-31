import { Request, Response, NextFunction } from 'express';
import { User } from '../models/User';
import { JWTUtils } from '../utils/jwt';
import { UserRole, IAuthRequest, IUser } from '../types';

/**
 * Authentication middleware
 */
export const authenticate = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const token = JWTUtils.extractTokenFromHeader(req.headers.authorization);

    if (!token) {
      res.status(401).json({
        success: false,
        message: 'Access token is required'
      });
      return;
    }

    // Verify token
    const decoded = JWTUtils.verifyAccessToken(token);

    // Find user
    const userDoc = await User.findById(decoded.userId).select('-password');

    if (!userDoc) {
      res.status(401).json({
        success: false,
        message: 'User not found'
      });
      return;
    }

    if (!userDoc.isActive) {
      res.status(401).json({
        success: false,
        message: 'Account is deactivated'
      });
      return;
    }

    // Convert Mongoose document to plain object and ensure _id is string
    const userObj = userDoc.toObject();
    const user = {
      _id: userObj._id?.toString(),
      email: userObj.email,
      firstName: userObj.firstName,
      lastName: userObj.lastName,
      mobile: userObj.mobile,
      role: userObj.role,
      password: userObj.password,
      isEmailVerified: userObj.isEmailVerified,
      isMobileVerified: userObj.isMobileVerified,
      isActive: userObj.isActive,
      profileImage: userObj.profileImage,
      savedLocations: userObj.savedLocations,
      pickupPreferences: userObj.pickupPreferences,
      lastLogin: userObj.lastLogin,
      createdAt: userObj.createdAt,
      updatedAt: userObj.updatedAt
    } as IUser;
    
    // Attach user to request
    req.user = user;
    
    // Attach user to request
    req.user = user;
    next();
  } catch (error) {
    res.status(401).json({
      success: false,
      message: 'Invalid or expired token'
    });
  }
};

/**
 * Role-based authorization middleware
 */
export const authorize = (...roles: UserRole[]) => {
  return (req: IAuthRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
      return;
    }

    if (!roles.includes(req.user.role)) {
      res.status(403).json({
        success: false,
        message: 'Insufficient permissions'
      });
      return;
    }

    next();
  };
};

/**
 * Admin only middleware
 */
export const adminOnly = authorize('admin');

/**
 * Manager and Admin middleware
 */
export const managerAndAdmin = authorize('admin', 'manager');

/**
 * All authenticated users middleware
 */
export const allUsers = authorize('admin', 'manager', 'user');

/**
 * Optional authentication middleware
 * (Doesn't fail if no token, but attaches user if token is valid)
 */
export const optionalAuth = async (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const token = JWTUtils.extractTokenFromHeader(req.headers.authorization);

    if (token) {
      try {
        const decoded = JWTUtils.verifyAccessToken(token);
        const userDoc = await User.findById(decoded.userId).select('-password');
        
        if (userDoc && userDoc.isActive) {
          // Convert Mongoose document to plain object and ensure _id is string
          const userObj = userDoc.toObject();
          const user = {
            _id: userObj._id?.toString(),
            email: userObj.email,
            firstName: userObj.firstName,
            lastName: userObj.lastName,
            mobile: userObj.mobile,
            role: userObj.role,
            password: userObj.password,
            isEmailVerified: userObj.isEmailVerified,
            isMobileVerified: userObj.isMobileVerified,
            isActive: userObj.isActive,
            profileImage: userObj.profileImage,
            savedLocations: userObj.savedLocations,
            pickupPreferences: userObj.pickupPreferences,
            lastLogin: userObj.lastLogin,
            createdAt: userObj.createdAt,
            updatedAt: userObj.updatedAt
          } as IUser;
          req.user = user;
        }
      } catch (error) {
        // Token is invalid, but we don't fail the request
        console.log('Invalid token in optional auth:', error);
      }
    }

    next();
  } catch (error) {
    next();
  }
};

/**
 * Email verification middleware
 */
export const requireEmailVerification = (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
): void => {
  if (!req.user) {
    res.status(401).json({
      success: false,
      message: 'Authentication required'
    });
    return;
  }

  if (!req.user.isEmailVerified) {
    res.status(403).json({
      success: false,
      message: 'Email verification required'
    });
    return;
  }

  next();
};

/**
 * Mobile verification middleware
 */
export const requireMobileVerification = (
  req: IAuthRequest,
  res: Response,
  next: NextFunction
): void => {
  if (!req.user) {
    res.status(401).json({
      success: false,
      message: 'Authentication required'
    });
    return;
  }

  if (!req.user.isMobileVerified) {
    res.status(403).json({
      success: false,
      message: 'Mobile verification required'
    });
    return;
  }

  next();
};

/**
 * Check if user can access resource
 */
export const canAccessResource = (resourceOwnerId: string) => {
  return (req: IAuthRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
      return;
    }

    // Admin can access everything
    if (req.user?.role === 'admin') {
      next();
      return;
    }

    // Manager can access their own resources
    if (req.user?.role === 'manager' && req.user?._id && req.user._id.toString() === resourceOwnerId) {
      next();
      return;
    }

    // User can only access their own resources
    if (req.user?._id && req.user._id.toString() === resourceOwnerId) {
      next();
      return;
    }

    res.status(403).json({
      success: false,
      message: 'Access denied'
    });
  };
};
