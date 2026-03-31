import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeBottomNavWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const HomeBottomNavWidget({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  static const List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.home_rounded,
      'iconOutline': Icons.home_outlined,
      'label': 'Home',
    },
    {
      'icon': Icons.receipt_long_rounded,
      'iconOutline': Icons.receipt_long_outlined,
      'label': 'Orders',
    },
    {
      'icon': Icons.featured_video_rounded,
      'iconOutline': Icons.featured_video_outlined,
      'label': 'Subs',
    },
    {
      'icon': Icons.account_balance_wallet_rounded,
      'iconOutline': Icons.account_balance_wallet_outlined,
      'label': 'Wallet',
    },
    {
      'icon': Icons.person_rounded,
      'iconOutline': Icons.person_outlined,
      'label': 'Profile',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final isSelected = selectedIndex == index;
              return Expanded(
                flex: isSelected ? 15 : 10,
                child: _NavItem(
                  icon: _navItems[index]['icon'] as IconData,
                  iconOutline: _navItems[index]['iconOutline'] as IconData,
                  label: _navItems[index]['label'] as String,
                  isSelected: isSelected,
                  onTap: () => onIndexChanged(index),
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
  final IconData icon;
  final IconData iconOutline;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconOutline,
    required this.label,
    required this.isSelected,
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
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    if (widget.isSelected) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isSelected ? 12 : 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? const Color(0xFFEC5B13)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              boxShadow: widget.isSelected ? [
                BoxShadow(
                  color: const Color(0xFFEC5B13).withAlpha(60),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ] : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isSelected ? widget.icon : widget.iconOutline,
                  size: 22,
                  color: widget.isSelected
                      ? Colors.white
                      : const Color(0xFF94A3B8),
                ),
                if (widget.isSelected) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
