import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class IssueTileWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const IssueTileWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  State<IssueTileWidget> createState() => _IssueTileWidgetState();
}

class _IssueTileWidgetState extends State<IssueTileWidget>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
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
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAEAE1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  color: const Color(0xFFD4541B),
                  size: 22,
                ),
              ),
              SizedBox(width: 3.5.w),
              Expanded(
                child: Text(
                  widget.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFAAAAAA),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
