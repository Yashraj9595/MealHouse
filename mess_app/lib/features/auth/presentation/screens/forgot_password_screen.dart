import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  void _resetPassword() {
    if (_emailController.text.contains('@')) {
      Navigator.pushNamed(context, AppRoutes.otpScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textHeader),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5.h),
            Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppColors.textHeader,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "Don't worry! It happens. Please enter the address associated with your account.",
              style: TextStyle(
                color: AppColors.textBody,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 6.h),
            _buildTextField(),
            SizedBox(height: 6.h),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(color: AppColors.textHeader, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: AppColors.textHeader),
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: const TextStyle(color: AppColors.textBody),
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary, size: 20.sp),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 7.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF818CF8)],
        ),
      ),
      child: ElevatedButton(
        onPressed: _resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          'Send Code',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
