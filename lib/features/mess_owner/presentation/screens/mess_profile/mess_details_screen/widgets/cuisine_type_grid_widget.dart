import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:meal_house/core/theme/app_theme.dart';

class CuisineTypeGridWidget extends StatelessWidget {
  final String selectedCuisine;
  final ValueChanged<String> onCuisineSelected;

  const CuisineTypeGridWidget({
    super.key,
    required this.selectedCuisine,
    required this.onCuisineSelected,
  });

  static const List<String> _cuisineOptions = [
    'North Indian',
    'South Indian',
    'Maharashtrian',
    'Mixed',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cuisine Type',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemCount: _cuisineOptions.length,
            itemBuilder: (context, index) {
              final cuisine = _cuisineOptions[index];
              final isSelected = selectedCuisine == cuisine;
              return _CuisineChip(
                label: cuisine,
                isSelected: isSelected,
                onTap: () => onCuisineSelected(cuisine),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CuisineChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CuisineChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CuisineChip> createState() => _CuisineChipState();
}

class _CuisineChipState extends State<_CuisineChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _animController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _animController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: widget.isSelected ? AppTheme.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primary
                  : AppTheme.borderColor,
              width: widget.isSelected ? 1.8 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
              color: widget.isSelected
                  ? AppTheme.primary
                  : AppTheme.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
