import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeSearchBarWidget extends StatefulWidget {
  final bool isListening;
  final VoidCallback onVoiceTap;

  const HomeSearchBarWidget({
    super.key,
    required this.isListening,
    required this.onVoiceTap,
  });

  @override
  State<HomeSearchBarWidget> createState() => _HomeSearchBarWidgetState();
}

class _HomeSearchBarWidgetState extends State<HomeSearchBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, size: 20, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search thali, mess, or meal type',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                isDense: true,
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Voice button
          GestureDetector(
            onTap: widget.onVoiceTap,
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.isListening
                    ? const Color(0xFFF97316).withAlpha(31)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: widget.isListening
                  ? ScaleTransition(
                      scale: _pulseAnim,
                      child: const Icon(
                        Icons.mic_rounded,
                        size: 20,
                        color: Color(0xFFF97316),
                      ),
                    )
                  : const Icon(
                      Icons.mic_outlined,
                      size: 20,
                      color: Color(0xFFF97316),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
