import multer from 'multer';
import path from 'path';
import { Request } from 'express';

// Set storage engine
const storage = multer.diskStorage({
  destination: (_req: Request, _file: any, cb: any) => {
    cb(null, './uploads/');
  },
  filename: (_req: Request, file: any, cb: any) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});

// Check file type
function checkFileType(file: any, cb: any) {
  const filetypes = /jpeg|jpg|png|webp/;
  const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = filetypes.test(file.mimetype);

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb('Error: Images only!');
  }
}

// Init upload
export const upload = multer({
  storage: storage,
  limits: { fileSize: 5000000 }, // 5MB limit
  fileFilter: (_req: Request, file: any, cb: any) => {
    checkFileType(file, cb);
  }
});
