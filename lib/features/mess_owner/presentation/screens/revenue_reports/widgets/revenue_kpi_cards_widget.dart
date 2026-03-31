import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class RevenueKpiCardsWidget extends StatelessWidget {
  final double totalRevenue;
  final int totalOrders;
  final String revenueChange;
  final String ordersChange;
  final bool isPositive;
  final bool isTablet;

  const RevenueKpiCardsWidget({
    super.key,
    required this.totalRevenue,
    required this.totalOrders,
    required this.revenueChange,
    required this.ordersChange,
    required this.isPositive,
    this.isTablet = false,
  });

  String _formatCurrency(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)}L';
    } else if (value >= 1000) {
      final formatted = value.toStringAsFixed(0);
      // Indian number formatting
      if (formatted.length > 3) {
        return '₹${formatted.substring(0, formatted.length - 3)},${formatted.substring(formatted.length - 3)}';
      }
      return '₹$formatted';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  String _formatOrders(int value) {
    if (value >= 1000) {
      final s = value.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'Total Revenue',
            value: _formatCurrency(totalRevenue),
            change: revenueChange,
            isPositive: isPositive,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            label: 'Total Orders',
            value: _formatOrders(totalOrders),
            change: ordersChange,
            isPositive: isPositive,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final bool isPositive;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = isPositive ? AppTheme.success : AppTheme.error;
    final changeIcon = isPositive
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(changeIcon, size: 14, color: changeColor),
              const SizedBox(width: 3),
              Text(
                change,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: changeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
