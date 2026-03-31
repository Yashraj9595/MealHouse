import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/auth/domain/repositories/auth_repository.dart';
import 'package:meal_house/features/auth/domain/entities/user.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _primaryOrange = Color(0xFFE85D19);
  static const _bgColor = Color(0xFFF5F5F5);

  final AuthRepository _authRepository = sl<AuthRepository>();
  User? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _firstNameController.text = user.firstName;
          _lastNameController.text = user.lastName;
          _phoneController.text = user.mobile;
          _emailController.text = user.email;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile')),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: _primaryOrange)) 
            : Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarSection(),
                    SizedBox(height: 4.h),
                    _buildFieldLabel('First Name'),
                    SizedBox(height: 1.h),
                    _buildInputField(
                      controller: _firstNameController,
                      icon: Icons.person,
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(height: 2.5.h),
                    _buildFieldLabel('Last Name'),
                    SizedBox(height: 1.h),
                    _buildInputField(
                      controller: _lastNameController,
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(height: 2.5.h),
                    _buildFieldLabel('Phone Number'),
                    SizedBox(height: 1.h),
                    _buildInputField(
                      controller: _phoneController,
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 2.5.h),
                    _buildFieldLabel('Email Address'),
                    SizedBox(height: 1.h),
                    _buildInputField(
                      controller: _emailController,
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                    ),
                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: 24,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Edit Profile',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE8C4B0), width: 3),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: _user?.profileImage,
                    fit: BoxFit.cover,
                    semanticLabel: 'User profile avatar',
                    errorWidget: Container(
                      color: const Color(0xFF6B9E9E),
                      child: const Icon(
                        Icons.person,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: -4,
                child: GestureDetector(
                  onTap: _onChangePhoto,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: _primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Center(
          child: GestureDetector(
            onTap: _onChangePhoto,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFADDD0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                'Change Photo',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _primaryOrange,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF4A5568),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: readOnly ? Colors.grey : Colors.black87,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(icon, color: _primaryOrange, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 52),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: _primaryOrange, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.8.h,
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      color: _bgColor,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: ElevatedButton(
        onPressed: _onUpdateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryOrange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 1.8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          elevation: 2,
        ),
        child: _isSaving 
            ? const SizedBox(
                height: 20, 
                width: 20, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              ) 
            : Text(
                'Update Profile',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _onChangePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() => _isLoading = true);
        final bytes = await image.readAsBytes();
        final String newPhotoUrl = await _authRepository.uploadProfilePhoto(bytes, image.name);
        setState(() {
          _user = _user?.copyWith(profileImage: newPhotoUrl);
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $e')),
        );
      }
    }
  }

  Future<void> _onUpdateProfile() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await _authRepository.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        mobile: _phoneController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: GoogleFonts.dmSans(fontSize: 14),
            ),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
        Navigator.of(context).maybePop(true); // Pop with truthy value to signal reload
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile: $e',
              style: GoogleFonts.dmSans(fontSize: 14),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
