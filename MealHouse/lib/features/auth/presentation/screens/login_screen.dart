import 'package:MealHouse/core/app_export.dart';
import 'package:MealHouse/routes/app_routes.dart';
import 'package:MealHouse/core/auth/user_session.dart';
import 'package:MealHouse/core/di/injection.dart';
import 'package:MealHouse/features/auth/domain/repositories/auth_repository.dart';
import 'package:MealHouse/core/services/secure_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final authRepo = getIt<AuthRepository>();
      final result = await authRepo.login(_emailController.text, _passwordController.text);
      
      setState(() => _isLoading = false);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
          );
        },
        (user) {
          UserSession().login(user.role);
          _navigateByRole(user.role);
        },
      );
    }
  }

  void _navigateByRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        break;
      case 'mess-owner':
      case 'mess_owner':
      case 'messowner':
        Navigator.pushReplacementNamed(context, AppRoutes.messOwnerDashboard);
        break;
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.userHomeScreen);
    }
  }

  void _quickLogin(String role) async {
    String roleValue = 'user';
    String id = 'user_123';
    
    switch (role) {
      case 'User':
        roleValue = 'user';
        id = 'user_123';
        break;
      case 'Mess Owner':
        roleValue = 'mess_owner';
        id = 'owner_123';
        break;
      case 'Admin':
        roleValue = 'admin';
        id = 'admin_123';
        break;
    }
    
    // Bypass backend authentication for development
    try {
      final storageService = getIt<SecureStorageService>();
      await storageService.saveToken('mock_token_$roleValue');
      await storageService.saveUserId(id);
    } catch (e) {
      debugPrint('Error saving mock storage: $e');
    }
    
    UserSession().login(roleValue);
    if (mounted) {
      _navigateByRole(roleValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: 100.h,
            width: 100.w,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: AppColors.textHeader,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Login to access your mess services',
                    style: TextStyle(
                      color: AppColors.textBody,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _buildTextField(
                    label: 'Email Address',
                    hint: 'Enter your email',
                    controller: _emailController,
                    iconName: AppIcons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter email';
                      if (!value.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  SizedBox(height: 3.h),
                  _buildTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    iconName: AppIcons.lock,
                    isPassword: true,
                    isPasswordVisible: _isPasswordVisible,
                    onToggleVisibility: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter password';
                      if (value.length < 6) return 'Password too short';
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPasswordScreen),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: AppColors.primary, fontSize: 13.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _buildLoginButton(),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.textBody, fontSize: 13.sp),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.registerScreen),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildQuickLoginSection(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String iconName,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textHeader,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          style: const TextStyle(color: AppColors.textHeader),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textBody),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CustomIconWidget(iconName: iconName, color: AppColors.primary, size: 20.sp),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: CustomIconWidget(
                      iconName: isPasswordVisible
                          ? AppIcons.visibility
                          : AppIcons.visibilityOff,
                      color: AppColors.textBody,
                      size: 20.sp,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorStyle: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 7.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
          'Login Now',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.surface)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Direct Login for Dev',
                style: TextStyle(color: AppColors.textBody, fontSize: 11.sp),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.surface)),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          _quickLoginBtn('User', AppIcons.profile),
          _quickLoginBtn('Mess Owner', AppIcons.restaurant),
          _quickLoginBtn('Admin', AppIcons.admin),
          ],
        ),
      ],
    );
  }

  Widget _quickLoginBtn(String label, String iconName) {
    return GestureDetector(
      onTap: () => _quickLogin(label),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: CustomIconWidget(iconName: iconName, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: TextStyle(color: AppColors.textBody, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}
