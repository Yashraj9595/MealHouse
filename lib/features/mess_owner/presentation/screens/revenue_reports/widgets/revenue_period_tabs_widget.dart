import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class RevenuePeriodTabsWidget extends StatelessWidget {
  final List<String> periods;
  final int selectedIndex;
  final ValueChanged<int> onPeriodChanged;

  const RevenuePeriodTabsWidget({
    super.key,
    required this.periods,
    required this.selectedIndex,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      child: Column(
        children: [
          Row(
            children: List.generate(periods.length, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onPeriodChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        periods[index],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          // Animated indicator line
          Stack(
            children: [
              Container(height: 2, color: AppTheme.divider),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left:
                    (MediaQuery.of(context).size.width / periods.length) *
                    selectedIndex,
                child: Container(
                  width: MediaQuery.of(context).size.width / periods.length,
                  height: 2,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
