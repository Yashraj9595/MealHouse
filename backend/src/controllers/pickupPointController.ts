import { Request, Response } from 'express';
import { PickupPoint } from '../models/PickupPoint';

export class PickupPointController {
  static async getAll(req: Request, res: Response): Promise<void> {
    try {
      const pickupPoints = await PickupPoint.find({ isActive: true });
      res.status(200).json({
        success: true,
        data: { pickupPoints }
      });
    } catch (error: any) {
      console.error('PickupPointController error:', error);
      res.status(500).json({ success: false, message: error.message || 'Server error' });
    }
  }

  // GET /pickup-points/nearby?lat=18.51&lon=73.81&maxDistance=20000
  static async getNearby(req: Request, res: Response): Promise<void> {
    try {
      const lat = parseFloat(req.query.lat as string);
      const lon = parseFloat(req.query.lon as string);
      const maxDistance = parseInt(req.query.maxDistance as string) || 20000; // metres, default 20 km

      if (isNaN(lat) || isNaN(lon)) {
        res.status(400).json({ success: false, message: 'Valid lat and lon query params are required' });
        return;
      }

      const pickupPoints = await PickupPoint.find({
        isActive: true,
        location: {
          $near: {
            $geometry: { type: 'Point', coordinates: [lon, lat] },
            $maxDistance: maxDistance,
          },
        },
      });

      res.status(200).json({
        success: true,
        data: { pickupPoints }
      });
    } catch (error: any) {
      console.error('PickupPointController getNearby error:', error);
      res.status(500).json({ success: false, message: error.message || 'Server error' });
    }
  }

  static async getOne(req: Request, res: Response): Promise<void> {
    try {
      const pickupPoint = await PickupPoint.findById(req.params.id);
      if (!pickupPoint) {
        res.status(404).json({ success: false, message: 'Pickup point not found' });
        return;
      }
      res.status(200).json({
        success: true,
        data: { pickupPoint }
      });
    } catch (error: any) {
      console.error('PickupPointController error:', error);
      res.status(500).json({ success: false, message: error.message || 'Server error' });
    }
  }

  static async create(req: Request, res: Response): Promise<void> {
    try {
      const pickupPoint = await PickupPoint.create(req.body);
      res.status(201).json({
        success: true,
        data: { pickupPoint }
      });
    } catch (error: any) {
      console.error('PickupPointController error:', error);
      res.status(500).json({ success: false, message: error.message || 'Server error' });
    }
  }

  static async update(req: Request, res: Response): Promise<void> {
    try {
      const pickupPoint = await PickupPoint.findByIdAndUpdate(req.params.id, req.body, { new: true });
      if (!pickupPoint) {
        res.status(404).json({ success: false, message: 'Pickup point not found' });
        return;
      }
      res.status(200).json({
        success: true,
        data: { pickupPoint }
      });
    } catch (error: any) {
      console.error('PickupPointController error:', error);
      res.status(500).json({ success: false, message: error.message || 'Server error' });
    }
  }

  static async delete(req: Request, res: Response): Promise<void> {
    try {
      const pickupPoint = await PickupPoint.findByIdAndDelete(req.params.id);
      if (!pickupPoint) {
        res.status(404).json({ success: false, message: 'Pickup point not found' });
        return;
      }
      res.status(200).json({
        success: true,
        message: 'Pickup point deleted successfully'
      });
    } catch (error: any) {
      console.error('PickupPointController error:', error);
      res.status(500).json({ success: false, message: error.message || 'Server error' });
    }
  }
}
