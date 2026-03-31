import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/app_export.dart';

class MealSlotButtonsWidget extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final bool isTablet;

  const MealSlotButtonsWidget({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final slots = [
      _SlotData(
        label: 'Breakfast',
        icon: Icons.coffee_rounded,
      ),
      _SlotData(
        label: 'Lunch',
        icon: Icons.wb_sunny_rounded,
      ),
      _SlotData(
        label: 'Dinner',
        icon: Icons.nightlight_round,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: slots.map((slot) {
          final isActive = slot.label == selected;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: slot.label != 'Dinner' ? 10 : 0),
              child: _SlotButton(
                data: slot,
                isActive: isActive,
                onTap: () {
                  onSelected(slot.label);
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SlotData {
  final String label;
  final IconData icon;
  const _SlotData({
    required this.label,
    required this.icon,
  });
}

class _SlotButton extends StatefulWidget {
  final _SlotData data;
  final bool isActive;
  final VoidCallback onTap;

  const _SlotButton({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_SlotButton> createState() => _SlotButtonState();
}

class _SlotButtonState extends State<_SlotButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _press;
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) {
        _press.forward();
        widget.onTap();
      },
      onTapCancel: () => _press.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.isActive ? AppTheme.primaryLight : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isActive ? AppTheme.primary : AppTheme.outline,
              width: widget.isActive ? 1.5 : 1,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(38),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Icon(
                widget.data.icon,
                color: widget.isActive
                    ? AppTheme.primary
                    : AppTheme.onSurfaceMuted,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                widget.data.label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isActive
                      ? AppTheme.primary
                      : AppTheme.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
