import 'package:flutter/material.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class LocationActionChipsWidget extends StatelessWidget {
  final bool isDetecting;
  final VoidCallback onCurrentLocation;
  final VoidCallback onSelectFromMap;

  const LocationActionChipsWidget({
    super.key,
    required this.isDetecting,
    required this.onCurrentLocation,
    required this.onSelectFromMap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            icon: isDetecting
                ? Icons.radio_button_checked_rounded
                : Icons.gps_fixed_rounded,
            label: isDetecting ? 'Detecting...' : 'Use Current Location',
            isLoading: isDetecting,
            isPrimary: true,
            onTap: onCurrentLocation,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionChip(
            icon: Icons.map_rounded,
            label: 'Select from map',
            isPrimary: false,
            onTap: onSelectFromMap,
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp: (_) {
        _scaleCtrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            gradient: widget.isPrimary ? AppTheme.primaryGradient : null,
            color: widget.isPrimary ? null : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : AppTheme.cardBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isPrimary
                    ? AppTheme.primary.withAlpha(71)
                    : Colors.black.withAlpha(13),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.isPrimary
                            ? Colors.white
                            : AppTheme.primary,
                      ),
                    )
                  : Icon(
                      widget.icon,
                      size: 16,
                      color: widget.isPrimary ? Colors.white : AppTheme.primary,
                    ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.isPrimary
                        ? Colors.white
                        : AppTheme.textPrimary,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
