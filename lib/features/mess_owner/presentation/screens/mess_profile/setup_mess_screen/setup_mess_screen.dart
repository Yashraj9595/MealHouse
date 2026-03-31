import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/core/router/app_routes.dart';

class SetupMessScreen extends StatelessWidget {
  const SetupMessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressHeader(),
                    SizedBox(height: 2.h),
                    _buildKitchenCard(),
                    SizedBox(height: 2.h),
                    _buildHeadingSection(),
                    SizedBox(height: 2.h),
                    _buildStepsList(),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP 1 OF 4',
              style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '25% Complete',
              style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8A8A8A),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 2.w : 0),
                decoration: BoxDecoration(
                  color: index == 0
                      ? AppTheme.primary
                      : const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildKitchenCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80',
              width: double.infinity,
              height: 28.h,
              fit: BoxFit.cover,
              semanticLabel:
                  'Modern kitchen with green cabinets, gas stove, range hood, and decorative items on counter',
              errorBuilder: (context, error, stackTrace) => Container(
                height: 28.h,
                color: const Color(0xFFF0F0F0),
                child: const Icon(
                  Icons.kitchen,
                  size: 60,
                  color: Color(0xFFCCCCCC),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5EE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF2D7A4F),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Verified Seller',
                      style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set Up Your Mess',
          style: GoogleFonts.dmSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          'Provide details about your mess so students can find and order meals easily.',
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStepsList() {
    final steps = [
      _StepItem(
        number: 1,
        title: 'Add mess details',
        subtitle: 'Name, description, and cuisine type.',
        isActive: true,
      ),
      _StepItem(
        number: 2,
        title: 'Upload mess photos',
        subtitle: 'Showcase your food and dining area.',
        isActive: false,
      ),
      _StepItem(
        number: 3,
        title: 'Set location',
        subtitle: 'Help students find your exact spot.',
        isActive: false,
      ),
      _StepItem(
        number: 4,
        title: 'Choose operating hours',
        subtitle: 'Specify lunch and dinner timings.',
        isActive: false,
      ),
    ];

    return Column(children: steps.map((step) => _buildStepItem(step)).toList());
  }

  Widget _buildStepItem(_StepItem step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: step.isActive
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: step.isActive
                  ? AppTheme.primary.withAlpha(20)
                  : const Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step.number}',
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: step.isActive
                      ? AppTheme.primary
                      : const Color(0xFF8A8A8A),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  step.subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8A8A),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 2.5.h),
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 6.5.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.messDetailsScreen),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Start Setup',
                style: GoogleFonts.dmSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              "I'll do this later",
              style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8A8A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem {
  final int number;
  final String title;
  final String subtitle;
  final bool isActive;

  const _StepItem({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.isActive,
  });
}
