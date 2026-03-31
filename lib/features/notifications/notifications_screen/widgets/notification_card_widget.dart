import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class NotificationCardWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    required this.onMarkRead,
    required this.onDelete,
  });

  static const _primaryOrange = Color(0xFFE85D19);
  static const _unreadBg = Color(0xFFFFF3ED);
  static const _readBg = Color(0xFFFFFFFF);
  static const _iconReadBg = Color(0xFFEEEEEE);
  static const _iconReadColor = Color(0xFF6B7280);

  IconData _resolveIcon(String iconKey) {
    switch (iconKey) {
      case 'delivery':
        return Icons.electric_moped_rounded;
      case 'subscription':
        return Icons.calendar_month_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'wallet_alert':
        return Icons.warning_amber_rounded;
      case 'announcement':
        return Icons.campaign_rounded;
      case 'promo':
        return Icons.celebration_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnread = notification['isUnread'] == true;
    final String iconKey = notification['iconKey'] as String? ?? 'default';
    final String title = notification['title'] as String? ?? '';
    final String body = notification['body'] as String? ?? '';
    final String timestamp = notification['timestamp'] as String? ?? '';

    return Dismissible(
      key: Key(notification['id'] as String),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: const Color(0xFFEF4444),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: isUnread ? onMarkRead : null,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
          decoration: BoxDecoration(
            color: isUnread ? _unreadBg : _readBg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isUnread ? 0.06 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent border for unread
                if (isUnread)
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: _primaryOrange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                  ),
                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.5.w,
                      vertical: 1.6.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon container
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isUnread ? _primaryOrange : _iconReadBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _resolveIcon(iconKey),
                            color: isUnread ? Colors.white : _iconReadColor,
                            size: 26,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A1A1A),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    timestamp,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isUnread
                                          ? _primaryOrange
                                          : const Color(0xFF999999),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                body,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF555555),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
