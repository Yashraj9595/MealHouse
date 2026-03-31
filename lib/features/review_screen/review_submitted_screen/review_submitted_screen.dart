import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:meal_house/core/router/app_routes.dart';

class ReviewSubmittedScreen extends StatelessWidget {
  const ReviewSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0EE),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1A1A1A),
            size: 24,
          ),
        ),
        title: Text(
          'Review Submitted',
          style: GoogleFonts.dmSans(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  children: [
                    SizedBox(height: 4.h),
                    // Large peach circle with orange checkmark circle
                    _buildSuccessCircle(),
                    SizedBox(height: 2.5.h),
                    // Three stars
                    _buildStars(),
                    SizedBox(height: 3.h),
                    // Thank You heading
                    Text(
                      'Thank You!',
                      style: GoogleFonts.dmSans(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    // Subtext
                    Text(
                      'Your feedback helps us improve and\nhelps others find the best meals.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B6B6B),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    // Review Verified card
                    _buildRewardCard(),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
            // Bottom buttons
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCircle() {
    return Container(
      width: 55.w,
      height: 55.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEDC4B3),
      ),
      child: Center(
        child: Container(
          width: 30.w,
          height: 30.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE85C0D),
          ),
          child: const Center(
            child: Icon(Icons.check, color: Colors.white, size: 36),
          ),
        ),
      ),
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.star, color: const Color(0xFFE85C0D), size: 20),
        SizedBox(width: 3.w),
        Icon(Icons.star, color: const Color(0xFFE85C0D), size: 26),
        SizedBox(width: 3.w),
        Icon(Icons.star, color: const Color(0xFFE85C0D), size: 20),
      ],
    );
  }

  Widget _buildRewardCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Orange-tinted reward icon box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E8),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Center(
              child: Icon(
                Icons.volunteer_activism,
                color: Color(0xFFE85C0D),
                size: 26,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Verified',
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                'You earned 10 reward points!',
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, 3.h),
      decoration: const BoxDecoration(color: Color(0xFFF5F0EE)),
      child: Column(
        children: [
          // Back to My Orders button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.myOrdersScreen,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85C0D),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
              child: Text(
                'Back to My Orders',
                style: GoogleFonts.dmSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          // Write Another Review text button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE85C0D),
              ),
              child: Text(
                'Write Another Review',
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE85C0D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
