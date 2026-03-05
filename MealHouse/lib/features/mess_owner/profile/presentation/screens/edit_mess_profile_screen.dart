import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MealHouse/core/app_export.dart';
import '../../domain/entities/mess_profile_entity.dart';
import '../state/mess_profile_providers.dart';

class EditMessProfileScreen extends ConsumerStatefulWidget {
  final MessProfileEntity? profile; // Optional initial data

  const EditMessProfileScreen({super.key, this.profile});

  @override
  ConsumerState<EditMessProfileScreen> createState() => _EditMessProfileScreenState();
}

class _EditMessProfileScreenState extends ConsumerState<EditMessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _operatingHoursController;
  bool _isVegOnly = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.messName ?? '');
    _descriptionController = TextEditingController(text: widget.profile?.description ?? '');
    _phoneController = TextEditingController(text: widget.profile?.phoneNumber ?? '');
    _addressController = TextEditingController(text: widget.profile?.address ?? '');
    _operatingHoursController = TextEditingController(text: widget.profile?.operatingHours ?? '');
    _isVegOnly = widget.profile?.isVegOnly ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _operatingHoursController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = MessProfileEntity(
        id: widget.profile?.id ?? '', // ID should ideally not be empty if editing
        messName: _nameController.text,
        description: _descriptionController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        operatingHours: _operatingHoursController.text,
        isVegOnly: _isVegOnly,
        images: widget.profile?.images ?? [],
        rating: widget.profile?.rating ?? 0.0,
      );

      final updateUseCase = ref.read(updateMessProfileUseCaseProvider);
      final result = await updateUseCase(updatedProfile);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: ${failure.message}')),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          ref.refresh(messProfileProvider); // Refresh the profile data
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Mess Profile")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextFormField(
                controller: _nameController,
                labelText: "Mess Name",
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 2.h),
              CustomTextFormField(
                controller: _descriptionController,
                labelText: "Description",
                maxLines: 3,
              ),
              SizedBox(height: 2.h),
              CustomTextFormField(
                controller: _phoneController,
                labelText: "Phone Number",
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 2.h),
              CustomTextFormField(
                controller: _addressController,
                labelText: "Address",
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
               SizedBox(height: 2.h),
              CustomTextFormField(
                controller: _operatingHoursController,
                labelText: "Operating Hours",
                hintText: "e.g. 8AM - 10PM",
              ),
              SizedBox(height: 2.h),
              SwitchListTile(
                title: const Text("Veg Only"),
                value: _isVegOnly,
                onChanged: (val) => setState(() => _isVegOnly = val),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple CustomTextFormField wrapper if not already existing, or reuse existing
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final int maxLines;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }
}
