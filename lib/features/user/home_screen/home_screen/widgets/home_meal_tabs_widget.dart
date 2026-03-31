import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeMealTabsWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const HomeMealTabsWidget({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  static const List<Map<String, dynamic>> _tabs = [
    {'label': 'Breakfast', 'icon': Icons.wb_twilight},
    {'label': 'Lunch', 'icon': Icons.wb_sunny_rounded},
    {'label': 'Dinner', 'icon': Icons.nightlight_round},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Transparent to match brand background
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.only(
                  right: index < _tabs.length - 1 ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF97316)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFFF97316).withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFF97316)
                        : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _tabs[index]['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : const Color(0xFFF97316),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _tabs[index]['label'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
