import { Request, Response, NextFunction } from 'express';
import { Mess } from '../models/Mess';
import { IAuthRequest, IApiResponse } from '../types';

export const createMess = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const { name, ownerName, mobile, description, cuisineType, address, longitude, latitude } = req.body;

    const mess = new Mess({
      name,
      ownerName,
      ownerId: req.user?._id,
      mobile,
      description,
      cuisineType,
      address,
      location: {
        type: 'Point',
        coordinates: [parseFloat(longitude), parseFloat(latitude)]
      }
    });

    await mess.save();

    const response: IApiResponse = {
      success: true,
      message: 'Mess registered successfully',
      data: mess
    };

    return res.status(201).json(response);
  } catch (error) {
    return next(error);
  }
};

export const getMesses = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { lat, lng, radius = 5000, cuisine } = req.query; // radius in meters

    let query: any = { isActive: true };

    if (cuisine) {
      query.cuisineType = cuisine;
    }

    if (lat && lng) {
      query.location = {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(lng as string), parseFloat(lat as string)]
          },
          $maxDistance: parseInt(radius as string)
        }
      };
    }

    const messes = await Mess.find(query);

    const response: IApiResponse = {
      success: true,
      message: 'Messes fetched successfully',
      data: messes
    };

    return res.status(200).json(response);
  } catch (error) {
    return next(error);
  }
};

export const getMessById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const mess = await Mess.findById(req.params.id);

    if (!mess) {
      return res.status(404).json({
        success: false,
        message: 'Mess not found'
      });
    }

    const response: IApiResponse = {
      success: true,
      message: 'Mess details fetched successfully',
      data: mess
    };

    return res.status(200).json(response);
  } catch (error) {
    return next(error);
  }
};

export const getMyMesses = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const messes = await Mess.find({ ownerId: req.user?._id });

    const response: IApiResponse = {
      success: true,
      message: 'Your messes fetched successfully',
      data: messes
    };

    return res.status(200).json(response);
  } catch (error) {
    return next(error);
  }
};

export const updateMess = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const mess = await Mess.findOne({ _id: req.params.id, ownerId: req.user?._id });

    if (!mess) {
      return res.status(404).json({
        success: false,
        message: 'Mess not found or unauthorized'
      });
    }

    const updates = req.body;
    if (updates.longitude && updates.latitude) {
      updates.location = {
        type: 'Point',
        coordinates: [parseFloat(updates.longitude), parseFloat(updates.latitude)]
      };
    }

    Object.assign(mess, updates);
    await mess.save();

    const response: IApiResponse = {
      success: true,
      message: 'Mess updated successfully',
      data: mess
    };

    return res.status(200).json(response);
  } catch (error) {
    return next(error);
  }
};

export const deleteMess = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const mess = await Mess.findOneAndDelete({ _id: req.params.id, ownerId: req.user?._id });

    if (!mess) {
      return res.status(404).json({
        success: false,
        message: 'Mess not found or unauthorized'
      });
    }

    const response: IApiResponse = {
      success: true,
      message: 'Mess deleted successfully'
    };

    return res.status(200).json(response);
  } catch (error) {
    return next(error);
  }
};

export const uploadImages = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.files || (req.files as Express.Multer.File[]).length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Please upload at least one image'
      });
    }

    const files = req.files as Express.Multer.File[];
    // Generate full URLs for the uploaded files
    const fileUrls = files.map(file => {
      // Use logic to get base URL, but for simplicity we return relative path from host
      return `/uploads/${file.filename}`;
    });

    return res.status(200).json({
      success: true,
      message: 'Images uploaded successfully',
      data: fileUrls
    });
  } catch (error) {
    return next(error);
  }
};

