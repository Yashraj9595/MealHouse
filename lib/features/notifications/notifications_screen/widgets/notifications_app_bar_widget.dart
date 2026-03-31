import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class NotificationsAppBarWidget extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback onBackTap;

  const NotificationsAppBarWidget({
    super.key,
    required this.onSettingsTap,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          // Back arrow
          GestureDetector(
            onTap: onBackTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: Colors.transparent),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1A1A1A),
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Notifications',
              style: GoogleFonts.dmSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Settings gear
          GestureDetector(
            onTap: onSettingsTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.settings,
                color: Color(0xFF1A1A1A),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
