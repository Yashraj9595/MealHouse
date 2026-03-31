import { Router } from 'express';
import { updateMenu, getMenuByMessId } from '../controllers/menuController';
import { authenticate } from '../middleware/auth';

const router = Router();

// Public routes
router.get('/:messId', getMenuByMessId);

// Protected routes
router.put('/', authenticate, updateMenu);

export default router;
