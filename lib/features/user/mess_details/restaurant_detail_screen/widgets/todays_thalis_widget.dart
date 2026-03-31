import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/features/mess_owner/domain/models/menu_model.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:meal_house/features/user/presentation/providers/menu_provider.dart';
import 'package:meal_house/features/user/mess_details/widgets/thali_card_widget.dart';

class TodaysThalisWidget extends StatefulWidget {
  final List<MenuItemModel> thalis;
  final Map<String, CartItem> cartItems;
  final Function(MenuItemModel item, int delta) onUpdateCart;
  final bool isTablet;
  final String selectedSlot;
  final MessModel mess;

  const TodaysThalisWidget({
    super.key,
    required this.thalis,
    required this.cartItems,
    required this.onUpdateCart,
    required this.isTablet,
    required this.selectedSlot,
    required this.mess,
  });

  @override
  State<TodaysThalisWidget> createState() => _TodaysThalisWidgetState();
}

class _TodaysThalisWidgetState extends State<TodaysThalisWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  List<Animation<double>> _itemAnimations = [];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300 + (widget.thalis.length * 60).clamp(0, 400),
      ),
    );
    _buildAnimations();
    _staggerController.forward();
  }

  @override
  void didUpdateWidget(covariant TodaysThalisWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.thalis.length != widget.thalis.length || 
        oldWidget.selectedSlot != widget.selectedSlot) {
      _staggerController.reset();
      _buildAnimations();
      _staggerController.forward();
    }
  }

  void _buildAnimations() {
    _itemAnimations = List.generate(widget.thalis.length, (i) {
      final start = (i * 0.12).clamp(0.0, 0.8);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.thalis.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: _EmptySlotWidget(slot: widget.selectedSlot),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${widget.selectedSlot} Thalis",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              Text(
                '${widget.thalis.length} ITEMS',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        if (widget.isTablet)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.isTablet ? 3 : 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemCount: widget.thalis.length,
              itemBuilder: (context, index) {
                final anim = index < _itemAnimations.length
                    ? _itemAnimations[index]
                    : const AlwaysStoppedAnimation(1.0);
                return FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(
                    scale: anim,
                    child: ThaliCardWidget(
                      item: widget.thalis[index],
                      quantity:
                          widget.cartItems[widget.thalis[index].name]?.quantity ?? 0,
                      onAdd: () => widget.onUpdateCart(
                        widget.thalis[index],
                        1,
                      ),
                      onRemove: () => widget.onUpdateCart(
                        widget.thalis[index],
                        -1,
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.dishDetailPath(widget.mess.id!, widget.thalis[index].id!),
                          arguments: {
                            'item': widget.thalis[index],
                            'mess': widget.mess,
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 8),
              itemCount: widget.thalis.length,
              itemBuilder: (context, index) {
                final anim = index < _itemAnimations.length
                    ? _itemAnimations[index]
                    : const AlwaysStoppedAnimation(1.0);
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: SizedBox(
                        width: 200,
                        child: ThaliCardWidget(
                          item: widget.thalis[index],
                          quantity:
                              widget.cartItems[widget.thalis[index].name]?.quantity ??
                              0,
                          onAdd: () => widget.onUpdateCart(
                            widget.thalis[index],
                            1,
                          ),
                          onRemove: () => widget.onUpdateCart(
                            widget.thalis[index],
                            -1,
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.dishDetailPath(widget.mess.id!, widget.thalis[index].id!),
                              arguments: {
                                'item': widget.thalis[index],
                                'mess': widget.mess,
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EmptySlotWidget extends StatelessWidget {
  final String slot;
  const _EmptySlotWidget({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.no_meals_rounded,
            size: 48,
            color: AppTheme.onSurfaceMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'No $slot thalis today',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check back later or browse other meal slots.',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppTheme.onSurfaceMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
