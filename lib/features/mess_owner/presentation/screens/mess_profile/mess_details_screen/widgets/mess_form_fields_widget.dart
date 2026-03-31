import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:meal_house/core/theme/app_theme.dart';

class MessFormFieldsWidget extends StatelessWidget {
  final TextEditingController messNameController;
  final TextEditingController ownerNameController;
  final TextEditingController phoneController;
  final TextEditingController descriptionController;
  final int descriptionCharCount;

  const MessFormFieldsWidget({
    super.key,
    required this.messNameController,
    required this.ownerNameController,
    required this.phoneController,
    required this.descriptionController,
    required this.descriptionCharCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Mess Name'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: messNameController,
            hintText: 'e.g., Sharma Homemade Mess',
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Mess name is required'
                : null,
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Owner Name'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: ownerNameController,
            hintText: 'e.g., Rajesh Sharma',
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Owner name is required'
                : null,
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Phone Number'),
          const SizedBox(height: 8),
          _buildPhoneField(),
          const SizedBox(height: 20),
          _buildFieldLabel('Short Description'),
          const SizedBox(height: 8),
          _buildDescriptionField(),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Max 150 characters',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppTheme.textMuted,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 1.5),
        ),
        errorStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: AppTheme.errorColor,
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Phone number is required';
        if (v.trim().length < 10) return 'Enter a valid 10-digit number';
        return null;
      },
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: '9876543210',
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppTheme.textMuted,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+91',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 20, color: AppTheme.borderColor),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 1.5),
        ),
        errorStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: AppTheme.errorColor,
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: descriptionController,
      maxLines: 4,
      minLines: 4,
      maxLength: 150,
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Description is required';
        return null;
      },
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppTheme.textPrimary,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText:
            'Tell customers about your specialties, home-cooked style, etc.',
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppTheme.textMuted,
          height: 1.5,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.errorColor, width: 1.5),
        ),
        errorStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: AppTheme.errorColor,
        ),
      ),
    );
  }
}
