import 'package:flutter/material.dart';
import 'package:meal_house/core/constants/meal_enum.dart';
import '../pickup_point_selection_screen.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class MealTypeSelectorWidget extends StatelessWidget {
  final MealType selected;
  final ValueChanged<MealType> onChanged;
  final bool isVertical;

  const MealTypeSelectorWidget({
    super.key,
    required this.selected,
    required this.onChanged,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              color: AppTheme.primary,
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              'Meals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        isVertical
            ? Column(
                children: MealType.values
                    .map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MealChip(
                          meal: m,
                          isSelected: selected == m,
                          onTap: () => onChanged(m),
                          isExpanded: true,
                        ),
                      ),
                    )
                    .toList(),
              )
            : Row(
                children: MealType.values
                    .map(
                      (m) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: m != MealType.dinner ? 10 : 0,
                          ),
                          child: _MealChip(
                            meal: m,
                            isSelected: selected == m,
                            onTap: () => onChanged(m),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }
}

class _MealChip extends StatefulWidget {
  final MealType meal;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isExpanded;

  const _MealChip({
    required this.meal,
    required this.isSelected,
    required this.onTap,
    this.isExpanded = false,
  });

  @override
  State<_MealChip> createState() => _MealChipState();
}

class _MealChipState extends State<_MealChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _label {
    switch (widget.meal) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  IconData get _icon {
    switch (widget.meal) {
      case MealType.breakfast:
        return Icons.breakfast_dining_rounded;
      case MealType.lunch:
        return Icons.lunch_dining_rounded;
      case MealType.dinner:
        return Icons.dinner_dining_rounded;
    }
  }

  String get _timeHint {
    switch (widget.meal) {
      case MealType.breakfast:
        return '7–10 AM';
      case MealType.lunch:
        return '12–2 PM';
      case MealType.dinner:
        return '7–10 PM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppTheme.primaryGradient : null,
            color: widget.isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.transparent
                  : AppTheme.cardBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? AppTheme.primary.withAlpha(77)
                    : Colors.black.withAlpha(10),
                blurRadius: widget.isSelected ? 14 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: widget.isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                _icon,
                color: widget.isSelected
                    ? Colors.white
                    : AppTheme.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.isSelected
                          ? Colors.white
                          : AppTheme.textPrimary,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  Text(
                    _timeHint,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: widget.isSelected
                          ? Colors.white.withAlpha(204)
                          : AppTheme.muted,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
