import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class NotificationFilterWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onFilterChanged;

  const NotificationFilterWidget({
    super.key,
    required this.selectedIndex,
    required this.onFilterChanged,
  });

  static const List<String> _filters = [
    'All',
    'Orders',
    'Subscriptions',
    'Wallet',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final isActive = selectedIndex == index;
          return GestureDetector(
            onTap: () => onFilterChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE85D19)
                    : const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _filters[index],
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF555555),
                  letterSpacing: 0.1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
