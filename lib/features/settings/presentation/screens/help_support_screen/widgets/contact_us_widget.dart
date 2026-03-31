import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import './contact_option_card_widget.dart';

class ContactUsWidget extends StatelessWidget {
  const ContactUsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTACT US',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF8A8A8A),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 1.5.h),
        _ChatSupportButton(),
        SizedBox(height: 1.5.h),
        Row(
          children: [
            Expanded(
              child: ContactOptionCardWidget(
                icon: Icons.email_outlined,
                label: 'Email Support',
                onTap: () {
                  // TODO: Launch email client
                },
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: ContactOptionCardWidget(
                icon: Icons.phone_outlined,
                label: 'Call Support',
                onTap: () {
                  // TODO: Launch phone dialer
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChatSupportButton extends StatefulWidget {
  @override
  State<_ChatSupportButton> createState() => _ChatSupportButtonState();
}

class _ChatSupportButtonState extends State<_ChatSupportButton>
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
          // TODO: Navigate to chat support screen
        },
        onTapCancel: () => _scaleController.reverse(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: const Color(0xFFD4541B),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: 4.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat Support',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Average wait time: 2 mins',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withAlpha(217),
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
