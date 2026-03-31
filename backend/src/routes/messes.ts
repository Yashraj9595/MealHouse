import { Router } from 'express';
import { createMess, getMesses, getMessById, getMyMesses, updateMess, deleteMess, uploadImages } from '../controllers/messController';
import { authenticate } from '../middleware/auth';
import { upload } from '../middleware/upload';

const router = Router();

// Public routes
router.get('/', getMesses);
router.get('/:id', getMessById);

// Protected routes
router.post('/', authenticate, createMess);
router.post('/upload', authenticate, upload.array('images', 5), uploadImages);
router.get('/my/messes', authenticate, getMyMesses);
router.put('/:id', authenticate, updateMess);
router.delete('/:id', authenticate, deleteMess);


export default router;
