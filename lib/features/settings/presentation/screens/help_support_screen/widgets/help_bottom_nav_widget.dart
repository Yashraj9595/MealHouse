import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpBottomNavWidget extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const HelpBottomNavWidget({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  static const List<Map<String, dynamic>> _navItemMaps = [
    {
      'label': 'Home',
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home_rounded,
    },
    {
      'label': 'Orders',
      'icon': Icons.receipt_long_outlined,
      'activeIcon': Icons.receipt_long_rounded,
    },
    {
      'label': 'Wallet',
      'icon': Icons.account_balance_wallet_outlined,
      'activeIcon': Icons.account_balance_wallet_rounded,
    },
    {
      'label': 'Profile',
      'icon': Icons.person_outline_rounded,
      'activeIcon': Icons.person_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
            children: List.generate(_navItemMaps.length, (index) {
              final item = _navItemMaps[index];
              final bool isActive = index == activeIndex;
              return Expanded(
                child: _NavItem(
                  label: item['label'] as String,
                  icon: item['icon'] as IconData,
                  activeIcon: item['activeIcon'] as IconData,
                  isActive: isActive,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: widget.isActive ? 48 : 0,
              height: widget.isActive ? 48 : 0,
              decoration: BoxDecoration(
                color: widget.isActive
                    ? const Color(0xFFD4541B).withAlpha(31)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  widget.isActive ? widget.activeIcon : widget.icon,
                  color: widget.isActive
                      ? const Color(0xFFD4541B)
                      : const Color(0xFF9E9E9E),
                  size: 24,
                ),
              ),
            ),
            if (!widget.isActive) ...[
              Icon(widget.icon, color: const Color(0xFF9E9E9E), size: 24),
            ],
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                color: widget.isActive
                    ? const Color(0xFFD4541B)
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
