import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MealHouse/core/app_export.dart';
import '../state/user_profile_providers.dart';
import '../../domain/entities/profile_entity.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(String userId) async {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = UserProfileEntity(
        id: userId,
        name: _nameController.text,
        email: _emailController.text, // Email usually read-only but sending back for model completeness
        phoneNumber: _phoneController.text,
        address: _addressController.text,
      );

      final updateUseCase = ref.read(updateUserProfileUseCaseProvider);
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
          ref.refresh(userProfileProvider);
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: userProfileAsync.when(
        data: (profile) {
          // Initialize controllers only once if empty
          if (_nameController.text.isEmpty) {
            _nameController.text = profile.name;
            _emailController.text = profile.email;
            _phoneController.text = profile.phoneNumber;
            _addressController.text = profile.address;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(6.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildAvatarSection(theme),
                  SizedBox(height: 5.h),
                  _buildEditField(theme, 'Full Name', _nameController, AppIcons.profile),
                  SizedBox(height: 3.h),
                  _buildEditField(theme, 'Email Address', _emailController, AppIcons.email, readOnly: true),
                  SizedBox(height: 3.h),
                  _buildEditField(theme, 'Phone Number', _phoneController, AppIcons.phone),
                  SizedBox(height: 3.h),
                  _buildEditField(theme, 'Address', _addressController, AppIcons.location),
                  SizedBox(height: 6.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _saveProfile(profile.id),
                      icon: const CustomIconWidget(iconName: AppIcons.save, color: Colors.white),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildAvatarSection(ThemeData theme) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: CustomIconWidget(
            iconName: AppIcons.profile,
            size: 60,
            color: AppColors.primary,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const CustomIconWidget(
              iconName: AppIcons.edit,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditField(
    ThemeData theme,
    String label,
    TextEditingController controller,
    String iconName, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textHeader,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          validator: (value) => value!.isEmpty ? "Required" : null,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CustomIconWidget(iconName: iconName, color: AppColors.primary, size: 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade200 : Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}
