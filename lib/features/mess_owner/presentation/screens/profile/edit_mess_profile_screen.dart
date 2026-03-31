import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:meal_house/features/mess_owner/domain/repositories/mess_repository.dart';

class EditMessProfileScreen extends StatefulWidget {
  final MessModel mess;

  const EditMessProfileScreen({super.key, required this.mess});

  @override
  State<EditMessProfileScreen> createState() => _EditMessProfileScreenState();
}

class _EditMessProfileScreenState extends State<EditMessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  
  bool _isLoading = false;
  final MessRepository _messRepository = sl<MessRepository>();
  final ImagePicker _picker = ImagePicker();
  String? _logoPath;
  bool _isLogoLocal = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mess.name);
    _phoneController = TextEditingController(text: widget.mess.mobile);
    _addressController = TextEditingController(text: widget.mess.address);
    _descriptionController = TextEditingController(text: widget.mess.description);
    _logoPath = widget.mess.logo;
    _isLogoLocal = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      setState(() {
        _logoPath = image.path;
        _isLogoLocal = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? finalLogo = _logoPath;
      if (_logoPath != null && _isLogoLocal) {
        final uploaded = await _messRepository.uploadImages([_logoPath!]);
        if (uploaded.isNotEmpty) {
          finalLogo = uploaded[0];
        }
      }

      final updates = {
        'name': _nameController.text.trim(),
        'mobile': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
        'logo': finalLogo,
      };

      await _messRepository.updateMess(widget.mess.id!, updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mess profile updated successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate success for refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Mess Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primary.withAlpha(51), width: 2),
                          ),
                          child: ClipOval(
                            child: _logoPath != null
                                ? _isLogoLocal
                                    ? kIsWeb
                                        ? Image.network(_logoPath!, fit: BoxFit.cover)
                                        : Image.file(File(_logoPath!), fit: BoxFit.cover)
                                    : Image.network(
                                        _logoPath!.startsWith('http') ? _logoPath! : 'http://localhost:5000$_logoPath',
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(Icons.business, size: 50, color: Colors.grey),
                                      )
                                : const Icon(Icons.business, size: 50, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickLogo,
                            child: const CircleAvatar(
                              backgroundColor: AppTheme.primary,
                              radius: 18,
                              child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('General Information'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Mess Name',
                    hint: 'Enter your mess business name',
                    icon: Icons.business_outlined,
                    validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Contact Number',
                    hint: 'Enter mobile number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v?.isEmpty == true ? 'Phone is required' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Location details'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    hint: 'Full address of your mess',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (v) => v?.isEmpty == true ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Story / Description'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'About your mess',
                    hint: 'Describe your specialties, quality, etc.',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
