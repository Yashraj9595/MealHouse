import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';
import 'package:meal_house/shared/widgets/status_badge_widget.dart';
import '../../data/models/order_model.dart';
import '../../domain/entities/order_status.dart';

class CancelledOrderCardWidget extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onReorder;

  const CancelledOrderCardWidget({
    super.key,
    required this.order,
    required this.onReorder,
  });

  @override
  State<CancelledOrderCardWidget> createState() =>
      _CancelledOrderCardWidgetState();
}

class _CancelledOrderCardWidgetState extends State<CancelledOrderCardWidget>
    with SingleTickerProviderStateMixin {
  BadgeStatus _mapOrderStatusToBadgeStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return BadgeStatus.confirmed;
      case OrderStatus.preparing:
        return BadgeStatus.preparing;
      case OrderStatus.delivered:
        return BadgeStatus.delivered;
      case OrderStatus.cancelled:
        return BadgeStatus.cancelled;
      default:
        return BadgeStatus.confirmed;
    }
  }

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
      end: 0.984,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(
                color: AppTheme.error.withAlpha(153),
                width: 3.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0.7,
                          0,
                        ]),
                        child: CustomImageWidget(
                          imageUrl: widget.order.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          semanticLabel: widget.order.imageSemanticLabel,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cancel_rounded,
                          size: 20,
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.order.mealName,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppTheme.textMuted.withAlpha(
                                  153,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadgeWidget(label: widget.order.status.name.toUpperCase(), status: _mapOrderStatusToBadgeStatus(widget.order.status)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${widget.order.date} • ${widget.order.providerName}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '₹${widget.order.price.toInt()} • ${widget.order.mealType}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: widget.onReorder,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.refresh_rounded,
                              size: 14,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Reorder this meal',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
