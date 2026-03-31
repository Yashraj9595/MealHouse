import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ContactOptionCardWidget extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ContactOptionCardWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<ContactOptionCardWidget> createState() =>
      _ContactOptionCardWidgetState();
}

class _ContactOptionCardWidgetState extends State<ContactOptionCardWidget>
    with SingleTickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _scaleController.reverse(),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 2.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: const Color(0xFFD4541B), size: 26),
              SizedBox(height: 1.h),
              Text(
                widget.label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
