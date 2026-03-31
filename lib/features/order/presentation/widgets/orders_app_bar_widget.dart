import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class OrdersAppBarWidget extends StatelessWidget {
  final bool isSearchVisible;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onBack;

  const OrdersAppBarWidget({
    super.key,
    required this.isSearchVisible,
    required this.searchController,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _AppBarIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: onBack,
                semanticLabel: 'Go back',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: isSearchVisible
                      ? _SearchField(
                          key: const ValueKey('search'),
                          controller: searchController,
                          onChanged: onSearchChanged,
                          onClose: onSearchToggle,
                        )
                      : Align(
                          key: const ValueKey('title'),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'My Orders',
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                ),
              ),
              if (!isSearchVisible) ...[
                _AppBarIconButton(
                  icon: Icons.search_rounded,
                  onTap: onSearchToggle,
                  semanticLabel: 'Search orders',
                ),
                const SizedBox(width: 4),
                _FilterIconButton(onTap: onFilterTap),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AppBarIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  const _AppBarIconButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  State<_AppBarIconButton> createState() => _AppBarIconButtonState();
}

class _AppBarIconButtonState extends State<_AppBarIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Icon(widget.icon, size: 22, color: AppTheme.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _FilterIconButton extends StatefulWidget {
  final VoidCallback onTap;

  const _FilterIconButton({required this.onTap});

  @override
  State<_FilterIconButton> createState() => _FilterIconButtonState();
}

class _FilterIconButtonState extends State<_FilterIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Filter orders',
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.tune_rounded,
                  size: 22,
                  color: AppTheme.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const _SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search_rounded, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: true,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: 'Search orders...',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}