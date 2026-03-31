import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import './notification_card_widget.dart';

class NotificationListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final AnimationController animationController;
  final VoidCallback onMarkAllRead;
  final ValueChanged<String> onMarkRead;
  final ValueChanged<String> onDelete;
  final bool hasUnread;

  const NotificationListWidget({
    super.key,
    required this.notifications,
    required this.animationController,
    required this.onMarkAllRead,
    required this.onMarkRead,
    required this.onDelete,
    required this.hasUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT',
                style: GoogleFonts.dmSans(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF888888),
                  letterSpacing: 1.2,
                ),
              ),
              if (hasUnread)
                GestureDetector(
                  onTap: onMarkAllRead,
                  child: Text(
                    'Mark all as read',
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE85D19),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        Expanded(
          child: notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 2.h),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    final delay = (index * 80).clamp(0, 400);
                    final startInterval = delay / 600.0;
                    final endInterval = (startInterval + 0.4).clamp(0.0, 1.0);

                    final animation = CurvedAnimation(
                      parent: animationController,
                      curve: Interval(
                        startInterval,
                        endInterval,
                        curve: Curves.easeOutCubic,
                      ),
                    );

                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: NotificationCardWidget(
                        notification: n,
                        onMarkRead: () => onMarkRead(n['id'] as String),
                        onDelete: () => onDelete(n['id'] as String),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 72,
            color: const Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications here',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll let you know when something\nhappens with your tiffin orders.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFFAAAAAA),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
