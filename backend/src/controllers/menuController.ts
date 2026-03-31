import { Request, Response, NextFunction } from 'express';
import { Menu } from '../models/Menu';
import { Mess } from '../models/Mess';
import { IAuthRequest, IApiResponse } from '../types';

export const updateMenu = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const { messId, items } = req.body;

    // Verify that the user owns this mess
    const mess = await Mess.findOne({ _id: messId, ownerId: req.user?._id });
    if (!mess) {
      return res.status(403).json({
        success: false,
        message: 'You are not authorized to update this menu'
      });
    }

    let menu = await Menu.findOne({ messId });

    if (menu) {
      menu.items = items;
      await menu.save();
    } else {
      menu = new Menu({ messId, items });
      await menu.save();
    }

    const response: IApiResponse = {
      success: true,
      message: 'Menu updated successfully',
      data: menu
    };

    return res.status(200).json(response);
  } catch (error) {
    return next(error);
  }
};

export const getMenuByMessId = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const menu = await Menu.findOne({ messId: req.params.messId });

    if (!menu) {
      return res.status(404).json({
        success: false,
        message: 'Menu not found for this mess'
      });
    }

    const response: IApiResponse = {
      success: true,
      message: 'Menu fetched successfully',
      data: menu
    };

    return res.status(200).json(response);
  } catch (error) {
    return next(error);
  }
};
