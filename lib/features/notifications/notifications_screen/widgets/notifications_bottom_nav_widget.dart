import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/router/app_routes.dart';

class NotificationsBottomNavWidget extends StatelessWidget {
  final int selectedIndex;
  final int unreadAlertCount;
  final ValueChanged<int> onTap;

  const NotificationsBottomNavWidget({
    super.key,
    required this.selectedIndex,
    required this.unreadAlertCount,
    required this.onTap,
  });

  static const _primaryOrange = Color(0xFFE85D19);
  static const _inactiveColor = Color(0xFF8A8A9A);

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Orders'},
      {'icon': Icons.calendar_month_outlined, 'label': 'Subscriptions'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final isActive = index == selectedIndex;
              final icon = items[index]['icon'] as IconData;
              final label = items[index]['label'] as String;
              final badge = index == 2 ? unreadAlertCount : 0;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (index == 4) {
                      Navigator.of(context).pushNamed(AppRoutes.profileScreen);
                    } else {
                      onTap(index);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              icon,
                              key: ValueKey(isActive),
                              size: 24,
                              color: isActive ? _primaryOrange : _inactiveColor,
                            ),
                          ),
                          if (badge > 0)
                            Positioned(
                              top: -4,
                              right: -6,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: _primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive ? _primaryOrange : _inactiveColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
