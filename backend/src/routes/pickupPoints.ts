import { Router } from 'express';
import { PickupPointController } from '../controllers/pickupPointController';
import { authenticate, adminOnly } from '../middleware/auth';

const router = Router();

// Public routes (authenticated)
router.get('/', authenticate, PickupPointController.getAll);
router.get('/nearby', authenticate, PickupPointController.getNearby);
router.get('/:id', authenticate, PickupPointController.getOne);

// Protected routes (Admin only)
router.post('/', authenticate, adminOnly, PickupPointController.create);
router.put('/:id', authenticate, adminOnly, PickupPointController.update);
router.delete('/:id', authenticate, adminOnly, PickupPointController.delete);

export default router;
