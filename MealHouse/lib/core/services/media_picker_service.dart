import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;

class MediaPickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery with permission handling
  Future<String?> pickImageFromGallery() async {
    try {
      // Request permission
      final status = await Permission.photos.request();
      
      if (status.isGranted || status.isLimited) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        
        return image?.path;
      } else if (status.isPermanentlyDenied) {
        // Open app settings if permission is permanently denied
        await permissions.openAppSettings();
        return null;
      }
      
      return null;
    } catch (e) {
      // Log error silently or use a dedicated logging service
      return null;
    }
  }

  /// Pick an image from camera with permission handling
  Future<String?> pickImageFromCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      
      if (status.isGranted) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        
        return image?.path;
      } else if (status.isPermanentlyDenied) {
        await permissions.openAppSettings();
        return null;
      }
      
      return null;
    } catch (e) {
      // Log error silently
      return null;
    }
  }

  /// Pick a video from gallery with permission handling
  Future<String?> pickVideoFromGallery() async {
    try {
      // Request permission
      final status = await Permission.photos.request();
      
      if (status.isGranted || status.isLimited) {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(minutes: 2),
        );
        
        return video?.path;
      } else if (status.isPermanentlyDenied) {
        await permissions.openAppSettings();
        return null;
      }
      
      return null;
    } catch (e) {
      // Log error
      return null;
    }
  }

  /// Pick a video from camera with permission handling
  Future<String?> pickVideoFromCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      
      if (status.isGranted) {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(minutes: 2),
        );
        
        return video?.path;
      } else if (status.isPermanentlyDenied) {
        await permissions.openAppSettings();
        return null;
      }
      
      return null;
    } catch (e) {
      // Log error
      return null;
    }
  }

  /// Show bottom sheet to choose between camera and gallery
  Future<String?> showImageSourcePicker({
    required Function(ImageSource) onSourceSelected,
  }) async {
    // This will be called from the UI layer
    return null;
  }
}
