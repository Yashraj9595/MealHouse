import 'package:flutter/material.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class PermissionIllustrationWidget extends StatefulWidget {
  const PermissionIllustrationWidget({super.key});

  @override
  State<PermissionIllustrationWidget> createState() =>
      _PermissionIllustrationWidgetState();
}

class _PermissionIllustrationWidgetState
    extends State<PermissionIllustrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) => Transform.scale(
              scale: _pulse.value,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(31),
                ),
              ),
            ),
          ),
          // Middle ring
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(46),
            ),
          ),
          // Inner circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(242),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(31),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppTheme.primary,
              size: 44,
            ),
          ),
          // Floating food icons
          Positioned(
            top: 16,
            left: 30,
            child: _FloatingIcon(
              icon: Icons.breakfast_dining_rounded,
              delay: 0,
            ),
          ),
          Positioned(
            top: 16,
            right: 30,
            child: _FloatingIcon(icon: Icons.lunch_dining_rounded, delay: 600),
          ),
          Positioned(
            bottom: 16,
            left: 50,
            child: _FloatingIcon(icon: Icons.dinner_dining_rounded, delay: 300),
          ),
          Positioned(
            bottom: 8,
            right: 50,
            child: _FloatingIcon(icon: Icons.local_dining_rounded, delay: 900),
          ),
        ],
      ),
    );
  }
}

class _FloatingIcon extends StatefulWidget {
  final IconData icon;
  final int delay;

  const _FloatingIcon({required this.icon, required this.delay});

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _y;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _y = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _y,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _y.value), child: child),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withAlpha(51),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(widget.icon, color: AppTheme.primary, size: 18),
      ),
    );
  }
}
