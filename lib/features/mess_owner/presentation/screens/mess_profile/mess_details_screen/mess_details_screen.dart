import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/core/router/app_routes.dart';
import './widgets/cuisine_type_grid_widget.dart';
import './widgets/mess_form_fields_widget.dart';
import './widgets/step_indicator_widget.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/features/mess_owner/presentation/providers/mess_registration_provider.dart';

class MessDetailsScreen extends ConsumerStatefulWidget {
  const MessDetailsScreen({super.key});

  @override
  ConsumerState<MessDetailsScreen> createState() => _MessDetailsScreenState();
}

class _MessDetailsScreenState extends ConsumerState<MessDetailsScreen> {
  // TODO: Replace with Riverpod/Bloc for production
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _messNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCuisine = 'Mixed';
  int _descriptionCharCount = 0;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {
        _descriptionCharCount = _descriptionController.text.length;
      });
    });
    
    // Initialize from provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(messRegistrationProvider);
      _messNameController.text = state.name;
      _ownerNameController.text = state.ownerName;
      _phoneController.text = state.mobile;
      _descriptionController.text = state.description;
      setState(() {
        _selectedCuisine = state.cuisineType;
      });
    });
  }

  @override
  void dispose() {
    _messNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onCuisineSelected(String cuisine) {
    setState(() {
      _selectedCuisine = cuisine;
    });
  }

  Future<void> _onContinue() async {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(messRegistrationProvider.notifier).updateDetails(
        name: _messNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        mobile: _phoneController.text.trim(),
        description: _descriptionController.text.trim(),
        cuisineType: _selectedCuisine,
      );
      
      Navigator.pushNamed(context, AppRoutes.uploadMessPhotosScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _buildAppBar(theme),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 560 : double.infinity,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 0 : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StepIndicatorWidget(
                              currentStep: 2,
                              totalSteps: 4,
                              progressPercent: 0.5,
                            ),
                            SizedBox(height: 2.h),
                            MessFormFieldsWidget(
                              messNameController: _messNameController,
                              ownerNameController: _ownerNameController,
                              phoneController: _phoneController,
                              descriptionController: _descriptionController,
                              descriptionCharCount: _descriptionCharCount,
                            ),
                            SizedBox(height: 1.h),
                            CuisineTypeGridWidget(
                              selectedCuisine: _selectedCuisine,
                              onCuisineSelected: _onCuisineSelected,
                            ),
                            SizedBox(height: 12.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildContinueButton(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          alignment: Alignment.center,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary,
            size: 20,
          ),
        ),
      ),
      centerTitle: true,
      title: Text(
        'Mess Details',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: -0.2,
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildContinueButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: Colors.transparent, width: 0)),
      ),
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: _onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.primary.withAlpha(179),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
