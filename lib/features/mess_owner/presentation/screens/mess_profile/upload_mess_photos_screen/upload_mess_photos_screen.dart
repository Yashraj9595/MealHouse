import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:meal_house/features/mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/features/mess_owner/presentation/providers/mess_registration_provider.dart';

class UploadMessPhotosScreen extends ConsumerStatefulWidget {
  final MessModel? initialMess;
  const UploadMessPhotosScreen({super.key, this.initialMess});

  @override
  ConsumerState<UploadMessPhotosScreen> createState() => _UploadMessPhotosScreenState();
}

class _UploadMessPhotosScreenState extends ConsumerState<UploadMessPhotosScreen> {
  // Blue theme colors matching the reference image
  static const Color _blueColor = Color(0xFFE8650A);
  static const Color _blueLightBg = Color(0xFFFDE8D8);

  bool _isSaving = false;
  final MessRepository _messRepository = sl<MessRepository>();
  final ImagePicker _picker = ImagePicker();

  late Map<String, dynamic> _logoSlot;
  late List<Map<String, dynamic>> _photoSlots;

  @override
  void initState() {
    super.initState();
    _logoSlot = {
      'image': widget.initialMess?.logo,
      'isLocal': false,
    };
    _photoSlots = [
      {'label': 'Mess Front View', 'image': widget.initialMess?.photos.isNotEmpty == true ? widget.initialMess!.photos[0] : null, 'isLocal': false},
      {'label': 'Kitchen Area', 'image': widget.initialMess?.photos.length != null && widget.initialMess!.photos.length > 1 ? widget.initialMess!.photos[1] : null, 'isLocal': false},
      {'label': 'Dining Area', 'image': widget.initialMess?.photos.length != null && widget.initialMess!.photos.length > 2 ? widget.initialMess!.photos[2] : null, 'isLocal': false},
      {'label': 'Food Sample', 'image': widget.initialMess?.photos.length != null && widget.initialMess!.photos.length > 3 ? widget.initialMess!.photos[3] : null, 'isLocal': false},
    ];
  }

  Future<void> _onUploadLogo() async {
    try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 50, // Logo can be smaller
        );
        
        if (image != null) {
            setState(() {
                _logoSlot['image'] = image.path;
                _logoSlot['isLocal'] = true;
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Mess Logo selected.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white),
                  ),
                  backgroundColor: _blueColor,
                ),
              );
            }
        }
    } catch (e) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error picking logo: $e'), backgroundColor: Colors.red),
            );
         }
    }
  }

  Future<void> _onUploadPhoto(int index) async {
    try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
        
        if (image != null) {
            setState(() {
                _photoSlots[index]['image'] = image.path;
                _photoSlots[index]['isLocal'] = true;
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Photo selected for "${_photoSlots[index]['label']}".',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white),
                  ),
                  backgroundColor: _blueColor,
                ),
              );
            }
        }
    } catch (e) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
            );
         }
    }
  }

  void _onAddMorePhotos() {
    setState(() {
       _photoSlots.add({'label': 'Additional Photo', 'image': null, 'isLocal': false});
    });
  }

  Future<void> _onContinue() async {
    setState(() => _isSaving = true);
    try {
        String? finalLogo = _logoSlot['image'] as String?;
        final List<String> finalPhotos = [];
        final List<String> localPathsToUpload = [];

        // Handle logo upload
        if (_logoSlot['image'] != null && _logoSlot['isLocal'] == true) {
            final uploadedLogo = await _messRepository.uploadImages([_logoSlot['image'] as String]);
            if (uploadedLogo.isNotEmpty) {
                finalLogo = uploadedLogo[0];
            }
        }

        // Handle photos upload
        for (int i = 0; i < _photoSlots.length; i++) {
            final slot = _photoSlots[i];
            if (slot['image'] != null) {
                if (slot['isLocal'] == true) {
                    localPathsToUpload.add(slot['image'] as String);
                } else {
                    finalPhotos.add(slot['image'] as String);
                }
            }
        }

        // Upload local images
        if (localPathsToUpload.isNotEmpty) {
            final uploadedUrls = await _messRepository.uploadImages(localPathsToUpload);
            finalPhotos.addAll(uploadedUrls);
        }
    
        if (widget.initialMess != null) {
            // Edit mode
            await _messRepository.updateMess(widget.initialMess!.id!, {
                'logo': finalLogo,
                'photos': finalPhotos,
            });
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!')),
                );
                Navigator.pop(context, true);
            }
        } else {
            // Registration mode
            if (finalLogo != null) {
                ref.read(messRegistrationProvider.notifier).updateLogo(finalLogo);
            }
            ref.read(messRegistrationProvider.notifier).updatePhotos(finalPhotos);
            Navigator.pushNamed(context, AppRoutes.messLocationScreen);
        }
    } catch (e) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
            );
        }
    } finally {
        if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 560 : double.infinity,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildStepIndicator(),
                          const SizedBox(height: 24),
                          _buildLogoUploadSection(),
                          const SizedBox(height: 24),
                          Text(
                            'Mess Photos',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Upload at least 2-3 photos of your mess.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPhotoGrid(),
                          const SizedBox(height: 20),
                          _buildAddMoreButton(),
                          const SizedBox(height: 16),
                          _buildInfoTip(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  _buildContinueButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _onUploadLogo,
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: _blueLightBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: _blueColor.withAlpha(50), width: 1),
                  ),
                  child: _logoSlot['image'] != null
                      ? ClipOval(
                          child: _logoSlot['isLocal'] == true
                              ? kIsWeb
                                  ? Image.network(_logoSlot['image'] as String, fit: BoxFit.cover)
                                  : Image.file(File(_logoSlot['image'] as String), fit: BoxFit.cover)
                              : Image.network(
                                  _logoSlot['image'].startsWith('http')
                                      ? _logoSlot['image']
                                      : 'http://localhost:5000${_logoSlot['image']}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(Icons.business, size: 40, color: Colors.grey),
                                ),
                        )
                      : Center(
                          child: Icon(Icons.business_rounded, size: 40, color: _blueColor),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: _blueColor,
                    radius: 14,
                    child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mess Logo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload your mess logo or a profile image.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF9E9E9E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          alignment: Alignment.center,
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A2E),
            size: 20,
          ),
        ),
      ),
      title: Text(
        'Upload Mess Photos',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
          letterSpacing: -0.2,
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step 3 of 4',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _blueColor,
              ),
            ),
            Text(
              '75% Complete',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.75,
            minHeight: 6,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation<Color>(_blueColor),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: _photoSlots.length,
      itemBuilder: (context, index) {
        return _buildPhotoSlot(index);
      },
    );
  }

  Widget _buildPhotoSlot(int index) {
    final slot = _photoSlots[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _onUploadPhoto(index),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFCCCCCC),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: slot['image'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          slot['isLocal'] == true
                            ? kIsWeb 
                                ? Image.network(slot['image'] as String, fit: BoxFit.cover)
                                : Image.file(File(slot['image'] as String), fit: BoxFit.cover)
                            : Image.network(
                                slot['image'].startsWith('http') 
                                    ? slot['image'] 
                                    : 'http://localhost:5000${slot['image']}', 
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 12,
                              child: const Icon(Icons.check, size: 16, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() => slot['image'] = null),
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 12,
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildDashedBorder(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 32, color: const Color(0xFFAAAAAA)),
                          const SizedBox(height: 8),
                          Text(
                            'Upload Photo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFAAAAAA),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          slot['label'] as String,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDashedBorder({required Widget child}) {
    return CustomPaint(painter: _DashedBorderPainter(), child: child);
  }

  Widget _buildAddMoreButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _onAddMorePhotos,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _blueColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '+  Add More Photos',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _blueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _blueColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Photos help customers trust your mess and attract more orders. High quality photos of hygiene and food are recommended.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: _blueColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final isLoading = _isSaving;
    final isEditMode = widget.initialMess != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: Colors.white,
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: isLoading ? null : _onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: _blueColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isEditMode ? 'Save Changes' : 'Continue',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    const radius = 12.0;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));

    final path = Path()..addRRect(rrect);
    final dashPath = _createDashedPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final dashPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final len = (distance + dashWidth).clamp(0, metric.length);
        dashPath.addPath(
          metric.extractPath(distance, len as double),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
