import '../../../../core/app_export.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/auth/user_session.dart';

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

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Default to user role for normal login simulation
      UserSession().login(UserRole.user);
      Navigator.pushReplacementNamed(context, AppRoutes.customerHomeScreen);
    }
  }

  void _quickLogin(String role) {
    switch (role) {
      case 'User':
        UserSession().login(UserRole.user);
        Navigator.pushReplacementNamed(context, AppRoutes.customerHomeScreen);
        break;
      case 'Mess Owner':
        UserSession().login(UserRole.messOwner);
        Navigator.pushReplacementNamed(context, AppRoutes.messOwnerDashboard);
        break;
      case 'Admin':
        UserSession().login(UserRole.admin);
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
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
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
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
            _quickLoginBtn('User', 'person_outline'),
            _quickLoginBtn('Mess Owner', 'restaurant_outline'),
            _quickLoginBtn('Admin', 'admin'),
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
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
