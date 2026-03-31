import 'package:flutter/material.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/shared/widgets/status_badge_widget.dart';

class PickupLocationCardWidget extends StatefulWidget {
  final Map<String, String> data;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  const PickupLocationCardWidget({
    super.key,
    required this.data,
    required this.isSelected,
    required this.index,
    required this.onTap,
  });

  @override
  State<PickupLocationCardWidget> createState() =>
      _PickupLocationCardWidgetState();
}

class _PickupLocationCardWidgetState extends State<PickupLocationCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _selectCtrl;
  late Animation<double> _selectScale;

  @override
  void initState() {
    super.initState();
    _selectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.isSelected ? 1.0 : 0.0,
    );
    _selectScale = CurvedAnimation(
      parent: _selectCtrl,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(PickupLocationCardWidget old) {
    super.didUpdateWidget(old);
    if (widget.isSelected != old.isSelected) {
      if (widget.isSelected) {
        _selectCtrl.forward();
      } else {
        _selectCtrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _selectCtrl.dispose();
    super.dispose();
  }

  Color _getDistanceColor(String dist) {
    final clean = dist.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(clean) ?? 0;
    final isKm = dist.contains('km');
    final meters = isKm ? value * 1000 : value;
    if (meters <= 400) return AppTheme.success;
    if (meters <= 700) return AppTheme.secondary;
    return AppTheme.accent;
  }

  int get _slotsAvailable =>
      int.tryParse(widget.data['availableSlots'] ?? '10') ?? 10;
  bool get _isLowSlots => _slotsAvailable <= 8;

  @override
  Widget build(BuildContext context) {
    final distColor = _getDistanceColor(widget.data['distance'] ?? '');

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          // Gradient accent left border — LOCKED technique
          border: Border(
            left: BorderSide(
              color: widget.isSelected ? AppTheme.primary : AppTheme.cardBorder,
              width: widget.isSelected ? 4 : 1.5,
            ),
            top: BorderSide(color: AppTheme.cardBorder, width: 1.5),
            right: BorderSide(color: AppTheme.cardBorder, width: 1.5),
            bottom: BorderSide(color: AppTheme.cardBorder, width: 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? AppTheme.primary.withAlpha(36)
                  : Colors.black.withAlpha(13),
              blurRadius: widget.isSelected ? 18 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: widget.isSelected
                          ? AppTheme.primaryGradient
                          : null,
                      color: widget.isSelected ? null : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: widget.isSelected
                          ? Colors.white
                          : AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.data['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                  fontFamily: 'Outfit',
                                  height: 1.2,
                                ),
                              ),
                            ),
                            if (widget.isSelected)
                              ScaleTransition(
                                scale: _selectScale,
                                child: StatusBadgeWidget(
                                  label: 'SELECTED',
                                  status: BadgeStatus.selected,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.data['address'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                            fontFamily: 'Outfit',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Metadata row
              Row(
                children: [
                  // Distance badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: distColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_walk_rounded,
                          size: 12,
                          color: distColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.data['distance'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: distColor,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Time slot
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.data['timeSlot'] ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Rating
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: AppTheme.secondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.data['rating'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondary,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Low slots warning
              if (_isLowSlots) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.accent.withAlpha(51)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 12,
                        color: AppTheme.accent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Only $_slotsAvailable slots left — book fast!',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.accent,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
