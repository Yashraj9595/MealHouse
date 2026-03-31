import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SearchBannerWidget extends StatefulWidget {
  final TextEditingController searchController;

  const SearchBannerWidget({super.key, required this.searchController});

  @override
  State<SearchBannerWidget> createState() => _SearchBannerWidgetState();
}

class _SearchBannerWidgetState extends State<SearchBannerWidget>
    with SingleTickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production
  late AnimationController _focusAnimController;
  late Animation<double> _borderAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _borderAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _focusAnimController, curve: Curves.easeOutCubic),
    );
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_focusNode.hasFocus) {
        _focusAnimController.forward();
      } else {
        _focusAnimController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusAnimController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAEAE1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How can we help you today?',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD4541B),
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            'Search for topics or select an issue below.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF5A5A5A),
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.8.h),
          AnimatedBuilder(
            animation: _borderAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color.lerp(
                      Colors.transparent,
                      const Color(0xFFD4541B),
                      _borderAnimation.value,
                    )!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: TextField(
              controller: widget.searchController,
              focusNode: _focusNode,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                hintText: 'Search help articles...',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFAAAAAA),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(
                    Icons.search_rounded,
                    color: _isFocused
                        ? const Color(0xFFD4541B)
                        : const Color(0xFFAAAAAA),
                    size: 22,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
