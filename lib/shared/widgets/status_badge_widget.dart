import 'package:flutter/material.dart';
import 'package:meal_house/core/theme/app_theme.dart';

enum BadgeStatus {
  confirmed,
  preparing,
  delivered,
  cancelled,
  pending,
  popular,
  bestSeller,
  healthy,
  homemade,
  budget,
  authentic,
  selected,
  available,
  unavailable,
  warning,
}

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final BadgeStatus status;

  const StatusBadgeWidget({
    super.key,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case BadgeStatus.confirmed:
        bgColor = AppTheme.successLight;
        textColor = AppTheme.success;
        break;
      case BadgeStatus.preparing:
        bgColor = AppTheme.primaryLight;
        textColor = AppTheme.primary;
        break;
      case BadgeStatus.delivered:
        bgColor = const Color(0xFFE0F2FE);
        textColor = const Color(0xFF0284C7);
        break;
      case BadgeStatus.cancelled:
        bgColor = const Color(0xFFFEE2E2);
        textColor = AppTheme.error;
        break;
      case BadgeStatus.popular:
      case BadgeStatus.bestSeller:
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFC2410C);
        break;
      case BadgeStatus.healthy:
      case BadgeStatus.homemade:
      case BadgeStatus.authentic:
        bgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF15803D);
        break;
      case BadgeStatus.budget:
        bgColor = const Color(0xFFF5F3FF);
        textColor = const Color(0xFF6D28D9);
        break;
      default:
        bgColor = AppTheme.surfaceVariant;
        textColor = AppTheme.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
