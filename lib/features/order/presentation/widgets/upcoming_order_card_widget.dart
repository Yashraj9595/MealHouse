import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';
import 'package:meal_house/shared/widgets/status_badge_widget.dart';
import '../../data/models/order_model.dart';
import '../../domain/entities/order_status.dart';

class UpcomingOrderCardWidget extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onViewDetails;

  const UpcomingOrderCardWidget({
    super.key,
    required this.order,
    required this.onViewDetails,
  });

  @override
  State<UpcomingOrderCardWidget> createState() =>
      _UpcomingOrderCardWidgetState();
}

class _UpcomingOrderCardWidgetState extends State<UpcomingOrderCardWidget>
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
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onViewDetails();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(
                color: const Color(0xFF7B1FA2).withAlpha(153),
                width: 3.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomImageWidget(
                        imageUrl: widget.order.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        semanticLabel: widget.order.imageSemanticLabel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusBadgeWidget(label: widget.order.status.name.toUpperCase(), status: _mapOrderStatusToBadgeStatus(widget.order.status)),
                              Text(
                                '₹${widget.order.price.toInt()}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.order.mealName,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.order.providerName,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: AppTheme.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${widget.order.mealType} • ${widget.order.timeSlot}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: Color(0xFF7B1FA2),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.order.date,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7B1FA2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.order.pickupLocation,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton(
                    onPressed: widget.onViewDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: BorderSide(
                        color: AppTheme.primary.withAlpha(128),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
